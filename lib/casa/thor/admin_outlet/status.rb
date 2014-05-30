require 'thor'
require 'fileutils'
require 'casa/thor/admin_outlet'

module CASA
  module Thor
    class AdminOutlet < ::Thor

      desc 'status', 'Status of the CASA engine'

      def status
        unless File.exists? pid_file_path
          say 'Not running', :red
        else
          pid = open(pid_file_path).read.strip.to_i
          say "Running (pid: #{pid})", :green
        end
      end

    end
  end
end
