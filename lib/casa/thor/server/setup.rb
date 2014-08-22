require 'thor'
require 'casa/thor/server'
require 'json'

module CASA
  module Thor
    class Server < ::Thor

      desc 'setup', 'Configure general server properties'

      def setup

        settings = {}

        settings['ssl'] = {
            'private_key_file' => '',
            'cert_chain_file' => ''
        }

        while settings['ssl']['private_key_file'].length == 0
          settings['ssl']['private_key_file'] = ask('SSL private key file location:').strip
        end

        while settings['ssl']['cert_chain_file'].length == 0
          settings['ssl']['cert_chain_file'] = ask('SSL certificate chain file location:').strip
        end

        File.open(server_settings_file_path, 'w') do |file|
          file.write settings.to_json
        end

        say "Saved server settings file -- #{server_settings_file_path}", :green

      end

    end
  end
end
