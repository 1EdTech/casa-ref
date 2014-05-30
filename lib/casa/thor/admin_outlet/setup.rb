require 'thor'
require 'casa/thor/admin_outlet'
require 'open-uri'
require 'rubygems/package'
require 'zlib'
require 'fileutils'
require 'bundler'
require 'systemu'

module Casa
  module Thor
    class AdminOutlet < ::Thor

      desc 'setup', 'Configure the CASA admin outlet'

      def setup

        download_zip!
        extract_zip!

        write_engine_config!

        Bundler.with_clean_env do

          Dir.chdir admin_outlet_dir_path do

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

      no_tasks do

        def download_zip!
          open(admin_outlet_setup_file_tgz, 'wb') { |file| file << open(admin_outlet_setup_download_url).read }
        end

        def extract_zip!
          tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(admin_outlet_setup_file_tgz))
          tar_extract.rewind
          tar_extract.each do |entry|
            local_file_name = entry.full_name.gsub(/^([^\/]*)\//, '')
            next if local_file_name == 'pax_global_header'
            absolute_path = admin_outlet_dir_path + local_file_name
            if entry.directory?
              FileUtils.mkdir_p absolute_path
            else
              File.open(absolute_path, 'w') { |file| file.write entry.read }
            end
          end
          tar_extract.close
        end

        def write_engine_config!
          File.open(admin_outlet_dir_path + 'src/config/engine.js', 'w') do |file|
            file.write "var EngineConfig = {
            url: '#{engine_url}',
            id: '#{engine_uuid}'
          }"
          end
        end

        def admin_outlet_setup_file_tgz
          @admin_outlet_setup_file_tgz ||= settings_dir_path + 'casa-admin-outlet.tgz'
        end

        def admin_outlet_setup_download_url
          'https://github.com/imsglobal/casa-admin-outlet/tarball/master'
        end

        def engine_uuid

          until @engine_uuid
            id = ask('Engine UUID:').strip
            if id =~ /\A[\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12}\z/i
              @engine_uuid = id
            else
              say 'Invalid format -- please try again', :red
            end
          end

          @engine_uuid

        end

        def engine_url

          unless @engine_url
            @engine_url = ask('Engine URL:').strip
          end

          @engine_url

        end

      end

    end
  end
end
