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

      def start

        compile! unless File.exists?(CASA::AdminOutlet::App.public_folder + 'blocks/blocks.js') and File.exists?(CASA::AdminOutlet::App.public_folder + 'blocks/blocks.css')

        start!

      end

      no_tasks do

        def compile!

          unless File.exists? engine_settings_file_path
            say "Engine configuration file missing -- #{engine_settings_file_path}", :red
            say 'Use `casa admin_outlet setup\' to define this file', [:red, :bold]
            abort
          end

          FileUtils.cp(engine_settings_file_path, gem_base_path + 'src/config/engine.js')

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
