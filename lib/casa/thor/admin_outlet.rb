require 'thor'
require 'pathname'
require 'casa/admin_outlet/app'

module CASA
  module Thor
    class AdminOutlet < ::Thor

      class_option :settings_dir,
                   :type => :string,
                   :default => '.casa',
                   :desc => 'Path for the configuration directory relative to the home directory'

      class_option :outlet_settings_file,
                   :type => :string,
                   :default => 'admin_outlet-engine_config.js',
                   :desc => 'Path relative to settings_dir for the admin outlet\'s engine config file'

      class_option :pid_file,
                   :type => :string,
                   :default => 'admin_outlet.pid',
                   :desc => 'Path relative to settings_dir for the admin outlet pid file when running'

      class_option :port,
                   :type => :string,
                   :default => 9601,
                   :desc => 'Port admin outlet will run on'

      no_tasks do

        def settings_dir_path
          @settings_dir_path ||= Pathname.new(ENV['HOME']) + options[:settings_dir]
        end

        def outlet_settings_file_path
          @outlet_settings_file_path ||= settings_dir_path + options[:outlet_settings_file]
        end

        def gem_base_path
          CASA::AdminOutlet::App.base_path
        end

        def pid_file_path
          @pid_file_path ||= settings_dir_path + options[:pid_file]
        end

        def port
          @port ||= options[:port]
        end

      end

    end
  end
end

Dir.glob(Pathname.new(__FILE__).parent.realpath + "admin_outlet/**/*.rb").each { |r| require r }