require 'thor'
require 'fileutils'
require 'systemu'
require 'bundler'
require 'casa/thor/admin_outlet'
require 'casa/admin_outlet/app'

module CASA
  module Thor
    class AdminOutlet < ::Thor

      desc 'start', 'Start the CASA admin outlet'

      method_option :rebuild,
                    :type => :boolean,
                    :default => false,
                    :desc => 'Rebuild the application CSS and JS such as after config changes'

      def start

        if options[:rebuild]
          FileUtils.rm_f CASA::AdminOutlet::App.public_folder + 'blocks/blocks.js'
          FileUtils.rm_f CASA::AdminOutlet::App.public_folder + 'blocks/blocks.css'
        end

        compile! unless File.exists?(CASA::AdminOutlet::App.public_folder + 'blocks/blocks.js') and File.exists?(CASA::AdminOutlet::App.public_folder + 'blocks/blocks.css')

        start!

      end

      no_tasks do

        def compile!

          unless File.exists? outlet_settings_file_path
            say "Engine configuration file missing -- #{outlet_settings_file_path}", :red
            say 'Use `casa admin_outlet setup\' to define this file', [:red, :bold]
            abort
          end

          FileUtils.cp(outlet_settings_file_path, gem_base_path + 'src/config/engine.js')

          Bundler.with_clean_env do

            Dir.chdir gem_base_path do

              status, stdout, stderr = systemu "npm install"
              if status.success?
                say 'Installed Node.js modules', :green
              else
                say stderr, :red
              end

              status, stdout, stderr = systemu "bundle install"
              if status.success?
                say 'Installed Ruby gems', :green
              else
                say stderr, :red
              end

              status, stdout, stderr = systemu "bundle exec blocks build"
              if status.success?
                say 'Compiled via WebBlocks', :green
              else
                say stderr, :red
              end

            end

          end

        end

        def start!
          Rack::Server.start rack_options
        end

        # ACCESSORS

        def rack_options
          unless @rack_options
            @rack_options = {
                :app => CASA::AdminOutlet::App,
                :daemonize => true,
                :pid => pid_file_path
            }
            @rack_options[:Port] = port
          end
          @rack_options
        end

      end

    end
  end
end
