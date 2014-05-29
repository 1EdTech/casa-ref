require 'thor'
require 'pathname'

module Casa
  module Thor
    class Engine < ::Thor

      class_option :settings_dir,
                   :type => :string,
                   :default => '.casa',
                   :desc => 'Path for the configuration directory relative to the home directory '

      class_option :engine_settings_file,
                   :type => :string,
                   :default => 'engine.json',
                   :desc => 'Path relative to settings_dir for the engine config file'

      class_option :attributes_settings_dir,
                   :type => :string,
                   :default => 'attributes',
                   :desc => 'Path relative to settings_dir for the directory of attribute config files'

      no_tasks do

        def settings_file_path
          @settings_file_path ||= Pathname.new(ENV['HOME']) + options[:settings_dir] + options[:engine_settings_file]
        end

        def attributes_settings_dir_path
          @attributes_settings_dir_path ||= Pathname.new(ENV['HOME']) + options[:settings_dir] + options[:attributes_settings_dir]
        end

      end

    end
  end
end

Dir.glob(Pathname.new(__FILE__).parent.realpath + "engine/**/*.rb").each { |r| require r }