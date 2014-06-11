require 'thor'
require 'casa/thor/engine'
require 'json'
require 'securerandom'
require 'fileutils'

module CASA
  module Thor
    class Engine < ::Thor

      desc 'setup', 'Configure the CASA engine'

      def setup

        settings = {}

        test_existing_settings_file!

        settings['id'] = engine_setup_id
        settings['rack'] = engine_setup_rack
        settings['modules'] = ['publisher','receiver','local','admin']
        settings['database'] = engine_setup_database
        settings['index'] = engine_setup_index
        settings['jobs'] = engine_setup_jobs
        settings['admin'] = engine_setup_admin

        save_settings settings

        save_attribute_definitions!

      end

      no_tasks do

        def test_existing_settings_file!

          if File.exists? settings_file_path
            say "Settings file already exists -- #{settings_file_path}", :green
            if yes? "Would you like to overwrite ('y' to overwrite)?"
              File.delete settings_file_path
              say 'Settings file deleted', :green
            else
              say 'SETUP ABORTED', :red
              abort
            end
          end

        end

        def engine_setup_id

          retval = nil

          while retval.nil?
            id = ask('UUID (empty for a generated one):').strip
            if id.length == 0
              retval = SecureRandom.uuid
              say "Using generated UUID: #{retval}", :cyan
            elsif id =~ /\A[\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12}\z/i
              retval = id
            else
              say 'Invalid format -- please try again', :red
            end
          end

          retval

        end

        def engine_setup_rack

          retval = {}

          port = ask('Port (empty for default port 9600):').strip
          retval[:port] = port.length > 0 ? port : 9600

          retval

        end

        def engine_setup_database

          adapter = engine_setup_database_adapter

          if adapter != 'sqlite'
            engine_setup_database_connection adapter
          else
            engine_setup_database_sqlite
          end

        end

        def engine_setup_database_adapter

          if yes? "Use mysql ('y' to use)?"
            'mysql2'
          elsif yes? "Use mssql ('y' to use)?"
            'tinytds'
          else
            say 'No database adapter specified -- using sqlite', :cyan
            'sqlite'
          end

        end

        def engine_setup_database_connection adapter

          conn = { :adapter => adapter }

          hostname = ask('Hostname:').strip
          conn[:host] = hostname.length > 0 ? hostname : 'localhost'

          conn[:user] = ask('Username:').strip

          password = ask('Password:').strip
          conn[:password] = password if password.length > 0

          conn[:database] = ask('Database:').strip

          conn

        end

        def engine_setup_database_sqlite

          {
              :adapter => 'sqlite',
              :database => ask('Database:').strip
          }

        end

        def engine_setup_jobs

          retval = {'intervals' => {}}

          {
              'receive_in' => 'ReceiveIn',
              'local_to_adj_out' => 'LocalToAdjOut',
              'adj_in_to_adj_out' => 'AdjInToAdjOut',
              'adj_in_to_local' => 'AdjInToLocal',
              'local_index_rebuild' => 'RebuildLocalIndex'
          }.each do |name, title|
            retval['intervals'][name] = ask("Refresh interval for #{title} (such as '30s', '10m', '2h' or '1d'):").strip
          end

          retval

        end

        def engine_setup_index

          adapter = engine_setup_index_adapter

          if adapter == 'elasticsearch'
            engine_setup_index_elasticsearch
          end

        end

        def engine_setup_index_adapter

          if yes? "Use ElasticSearch ('y' to use)?"
            'elasticsearch'
          else
            say 'No indexer will be used', :cyan
            false
          end

        end

        def engine_setup_index_elasticsearch

          index = { :type => 'elasticsearch', :hosts => [] }

          host = ask('Elasticsearch Host (empty when finished):').strip
          while host.length > 0
            index[:hosts] << host
            host = ask('Elasticsearch Host (empty when finished):').strip
          end

          index

        end

        def engine_setup_admin

          retval = {}

          retval[:username] = ask('Admin Outlet Username:').strip
          retval[:password] = ask('Admin Outlet Password:').strip
          retval[:origin] = ask('Admin Outlet Origin:').strip

          retval

        end

        def save_settings settings
          FileUtils.mkdir_p settings_file_path.parent
          File.open(settings_file_path, 'w+') {|f| f.write settings.to_json }
          say "Settings file saved to #{settings_file_path}", :green
        end

        def save_attribute_definitions!

          FileUtils.mkdir_p attributes_settings_dir_path

          [
            {
              "name" => "author",
              "class" => "CASA::Attribute::Author"
            },
            {
                "name" => "categories",
                "class" => "CASA::Attribute::Categories"
            },
            {
                "name" => "description",
                "class" => "CASA::Attribute::Description"
            },
            {
                "name" => "explicit",
                "class" => "CASA::Attribute::Explicit"
            },
            {
                "name" => "icon",
                "class" => "CASA::Attribute::Icon"
            },
            {
                "name" => "organization",
                "class" => "CASA::Attribute::Organization"
            },
            {
                "name" => "tags",
                "class" => "CASA::Attribute::Tags"
            },
            {
                "name" => "title",
                "class" => "CASA::Attribute::Title"
            }
          ].each do |attribute|

            File.open(attributes_settings_dir_path + "#{attribute['name']}.json", 'w') do |f|
              f.write({
                'name' => attribute['name'],
                'class' => attribute['class']
              }.to_json)
            end

          end

        end

      end

    end
  end
end
