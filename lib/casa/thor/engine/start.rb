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

        apps = [
            CASA::Engine::App,
            CASA::Engine::AdminApp
        ]

        unless File.exists? settings_file_path
          abort "\e[31m\e[1mSettings file `#{settings_file_path}` is not defined\e[0m\n\e[31mRun 'casa engine setup' to resolve"
        end

        settings = JSON::parse File.read settings_file_path

        logger = ::Logger.new STDOUT
        logger.level = ::Logger::DEBUG
        logger.datetime_format = '%Y-%m-%d %H:%M:%S'

        attributes_default_options = {}
        CASA::Engine::Attribute::Loader.new(attributes_settings_dir_path).definitions.each do |attribute|
          attributes_default_options[attribute['name']] = attribute['options'] if attribute.has_key? 'options'
          CASA::Attribute::Loader.load! attribute
        end
        attributes = CASA::Attribute::Loader.loaded

        apps.each do |app|
          app.set settings
          app.set :attributes_default_options, attributes_default_options
          app.set :attributes, attributes
          app.set :apps, apps
          app.set :logger, CASA::Support::ScopedLogger.new_without_scope(logger)
        end

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

        sequel_connection = Sequel.connect settings['database'].inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

        {
            'adj_in_payloads' => 'AdjInPayloads',
            'adj_in_peers' => 'AdjInPeers',
            'adj_out_payloads' => 'AdjOutPayloads',
            'attributes' => 'Attributes',
            'local_payloads' => 'LocalPayloads'
        }.each do |key, name|

          require "casa/engine/persistence/#{key}/sequel_storage_handler"
          klass = "CASA::Engine::Persistence::#{name}::SequelStorageHandler".split('::').inject(Object) {|o,c| o.const_get c}

          apps.each do |app|
            app.set "#{key}_handler".to_sym, klass.new({:context => app.settings, :db => sequel_connection})
          end

        end

        require 'elasticsearch'
        elasticsearch_client = Elasticsearch::Client.new 'log' => true

        begin

          require 'casa/engine/persistence/local_payloads/elasticsearch_storage_handler'
          klass = CASA::Engine::Persistence::LocalPayloads::ElasticsearchStorageHandler

          apps.each do |app|
            app.set :local_payloads_index_handler, klass.new({
                                                                 :context => app.settings,
                                                                 :db => elasticsearch_client,
                                                                 :schema_class => false
                                                             })
          end


        rescue

          logger.warn('Initialize - Index') { 'Could not initialize Elasticsearch - advanced search functions will not be available' }

        end

        CASA::Engine::App.attributes_handler.get_all.each do |row|
          options = JSON.parse row[:options]
          apps.each { |app| app.attributes[row[:name]].options = options }
        end

        ['configure','routes','start'].each do |type|
          settings['modules'].each do |mod|
            mod = 'admin/engine' if mod == 'admin'
            begin
              require "casa/engine/module/#{mod}/#{type}"
              logger.info("Module - #{mod[0,1].upcase}#{mod[1,mod.size-1]}"){ "loaded casa/engine/module/#{mod}/#{type}" }
            rescue LoadError
            end
          end
        end

        require 'casa/engine/module/admin/engine/routes.rb'

        app = Rack::URLMap.new({
          "/" => CASA::Engine::App,
          "/admin" => CASA::Engine::AdminApp
        })

        Rack::Server.start(:app => app)

      end

    end
  end
end
