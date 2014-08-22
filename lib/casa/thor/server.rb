require 'thor'
require 'pathname'
require 'casa/admin_outlet/app'

module CASA
  module Thor
    class Server < ::Thor

      class_option :settings_dir,
                   :type => :string,
                   :default => '.casa',
                   :desc => 'Path for the configuration directory relative to the home directory'

      class_option :server_settings_file,
                   :type => :string,
                   :default => 'server.json',
                   :desc => 'Path relative to settings_dir for the server config file'

      no_tasks do

        def settings_dir_path
          @settings_dir_path ||= Pathname.new(ENV['HOME']) + options[:settings_dir]
        end

        def server_settings_file_path
          @server_settings_file_path ||= settings_dir_path + options[:server_settings_file]
        end

      end

    end
  end
end

Dir.glob(Pathname.new(__FILE__).parent.realpath + "server/**/*.rb").each { |r| require r }