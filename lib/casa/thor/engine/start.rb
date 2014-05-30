require 'thor'
require 'sequel'
require 'casa/thor/engine'
require 'casa/engine/app'
require 'casa/engine/admin_app'
require 'casa/attribute/loader'
require 'casa/engine/attribute/loader'
require 'casa/support/scoped_logger'

module Casa
  module Thor
    class Engine < ::Thor

      desc 'start', 'Start the CASA engine'

      def start

        load_engine_settings!
        load_attribute_default_settings!
        load_attribute_settings!
        attach_apps!
        attach_logger!
        attach_database!
        attach_index!
        update_attribute_settings_from_database!
        require_modules!
        start!

      end

      no_tasks do

        # ACTIONS

        def attach_apps!
          apps.each do |app|
            app.set :apps, apps
          end
        end

        def attach_database!
          persistence_layers.each do |key, name|
            require "casa/engine/persistence/#{key}/sequel_storage_handler"
            klass = "CASA::Engine::Persistence::#{name}::SequelStorageHandler".split('::').inject(Object) {|o,c| o.const_get c}
            apps.each do |app|
              app.set "#{key}_handler".to_sym, klass.new({:context => app.settings, :db => sequel_connection})
            end
          end
        end

        def attach_index!
          if settings['index']['type'] == 'elasticsearch'
            load_elasticsearch_index!
          else
            logger.warn('Initialize - Index') do
              'Indexer not configured - advanced search functions will not be available'
            end
          end
        end

        def attach_logger!
          apps.each do |app|
            app.set :logger, CASA::Support::ScopedLogger.new_without_scope(logger)
          end
        end

        def load_attribute_default_settings!
          apps.each do |app|
            app.set :attributes_default_options, attributes_default_options
          end
        end

        def load_attribute_settings!
          apps.each do |app|
            app.set :attributes, attributes
          end
        end

        def load_elasticsearch_index!
          begin
            apps.each do |app|
              app.set :local_payloads_index_handler, elasticsearch_storage_handler_class.new({
                :context => app.settings,
                :db => elasticsearch_client,
                :schema_class => false
              })
            end
            logger.info('Initialize - Index') do
              'Initialized Elasticsearch'
            end
          rescue
            logger.warn('Initialize - Index') do
              'Could not initialize Elasticsearch - advanced search functions will not be available'
            end
          end
        end

        def load_engine_settings!
          apps.each do |app|
            app.set settings
          end
        end

        def require_modules!
          ['configure','routes','start'].each do |type|
            settings['modules'].each do |mod|
              mod = 'admin/engine' if mod == 'admin'
              begin
                require "casa/engine/module/#{mod}/#{type}"
                logger.info("Module - #{mod[0,1].upcase}#{mod[1,mod.size-1]}"){ "Loaded casa/engine/module/#{mod}/#{type}" }
              rescue LoadError
              end
            end
          end
        end

        def start!
          Rack::Server.start rack_options
        end

        # ACCESSORS

        def apps
          @apps ||= [ CASA::Engine::App, CASA::Engine::AdminApp ]
        end

        def attributes
          unless @attributes
            CASA::Engine::Attribute::Loader.new(attributes_settings_dir_path).definitions.each do |attribute|
              CASA::Attribute::Loader.load! attribute
            end
            @attributes = CASA::Attribute::Loader.loaded
          end
          @attributes
        end

        def attributes_default_options
          unless @attributes_default_options
            attributes_default_options = {}
            CASA::Engine::Attribute::Loader.new(attributes_settings_dir_path).definitions.each do |attribute|
              attributes_default_options[attribute['name']] = attribute['options'] if attribute.has_key? 'options'
            end
          end
          @attributes_default_options
        end

        def elasticsearch_client
          unless @elasticsearch_client
            require 'elasticsearch'
            @elasticsearch_client = Elasticsearch::Client.new elasticsearch_client_options
          end
          @elasticsearch_client
        end

        def elasticsearch_client_options
          unless @elasticsearch_client_options
            @elasticsearch_client_options = {
              'log' => true
            }
            @elasticsearch_client_options['hosts'] = settings['index']['hosts'] if settings['index']['hosts']
          end
          @elasticsearch_client_options
        end

        def elasticsearch_storage_handler_class
          require 'casa/engine/persistence/local_payloads/elasticsearch_storage_handler'
          CASA::Engine::Persistence::LocalPayloads::ElasticsearchStorageHandler
        end

        def logger
          unless @logger
            @logger = ::Logger.new STDOUT
            @logger.level = ::Logger::DEBUG
            @logger.datetime_format = '%Y-%m-%d %H:%M:%S'
          end
          @logger
        end

        def persistence_layers
          @persistence_layers ||= {
              'adj_in_payloads' => 'AdjInPayloads',
              'adj_in_peers' => 'AdjInPeers',
              'adj_out_payloads' => 'AdjOutPayloads',
              'attributes' => 'Attributes',
              'local_payloads' => 'LocalPayloads'
          }
        end

        def rack_app
          @rack_app ||= Rack::URLMap.new({
            "/" => CASA::Engine::App,
            "/admin" => CASA::Engine::AdminApp
          })
        end

        def rack_options
          unless @rack_options
            @rack_options = {
                :app => rack_app,
                :daemonize => true,
                :pid => pid_file_path
            }
            @rack_options[:Port] = settings['rack']['port'] if settings['rack'].include? 'port'
          end
          @rack_options
        end

        def sequel_connection
          unless @sequel_connection
            deps = {
                'mysql2' => ['mysql2'],
                'tinytds' => ['tiny_tds'],
                'sqlite' => ['sqlite3']
            }[settings['database']['adapter']].each do |dep|
              begin
                require dep
              rescue LoadError
                abort "\e[31m\e[1mDatabase adapter '#{settings['database']['adapter']}' requires `#{dep}' gem\e[0m\n\e[31mRun 'bundle install' to resolve (must not '--without #{settings['database']['adapter']}')'"
              end
            end
            @sequel_connection = Sequel.connect settings['database'].inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
          end
          @sequel_connection
        end

        def settings
          unless @settings
            abort "\e[31m\e[1mSettings file `#{settings_file_path}` is not defined\e[0m\n\e[31mRun 'casa engine setup' to resolve\e[0m" unless File.exists? settings_file_path
            @settings = JSON::parse File.read settings_file_path
          end
          @settings
        end

        def update_attribute_settings_from_database!
          CASA::Engine::App.attributes_handler.get_all.each do |row|
            options = JSON.parse row[:options]
            apps.each { |app| app.attributes[row[:name]].options = options }
          end
        end

      end

    end
  end
end
