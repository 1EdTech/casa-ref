require 'thor'
require 'casa/thor/admin_outlet'

module CASA
  module Thor
    class AdminOutlet < ::Thor

      desc 'setup', 'Configure the CASA admin outlet'

      def setup
        write_engine_config_file!
      end

      no_tasks do

        def write_engine_config_file!
          File.open(engine_settings_file_path, 'w') do |file|
            file.write "var EngineConfig = {
            url: '#{admin_outlet_setup_engine_url}',
            id: '#{admin_outlet_setup_engine_uuid}'
          }"
          end
        end

        def admin_outlet_setup_engine_uuid

          until @admin_outlet_setup_engine_uuid
            id = ask('Engine UUID:').strip
            if id =~ /\A[\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12}\z/i
              @admin_outlet_setup_engine_uuid = id
            else
              say 'Invalid format -- please try again', :red
            end
          end

          @admin_outlet_setup_engine_uuid

        end

        def admin_outlet_setup_engine_url

          unless @admin_outlet_setup_engine_url
            @admin_outlet_setup_engine_url = ask('Engine URL:').strip
          end

          @admin_outlet_setup_engine_url

        end

      end

    end
  end
end
