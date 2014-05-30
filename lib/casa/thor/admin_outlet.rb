require 'thor'
require 'pathname'

module Casa
  module Thor
    class AdminOutlet < ::Thor

      class_option :settings_dir,
                   :type => :string,
                   :default => '.casa',
                   :desc => 'Path for the configuration directory relative to the home directory '

      class_option :admin_outlet_dir,
                   :type => :string,
                   :default => 'casa-admin-outlet',
                   :desc => 'Path relative to settings_dir for the CASA admin outlet directory'

      no_tasks do

        def settings_dir_path
          @settings_dir_path ||= Pathname.new(ENV['HOME']) + options[:settings_dir]
        end

        def admin_outlet_dir_path
          @admin_outlet_dir_path ||= settings_dir_path + options[:admin_outlet_dir]
        end

      end

    end
  end
end

Dir.glob(Pathname.new(__FILE__).parent.realpath + "admin_outlet/**/*.rb").each { |r| require r }