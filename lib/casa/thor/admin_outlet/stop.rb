require 'thor'
require 'fileutils'
require 'casa/thor/admin_outlet'

module CASA
  module Thor
    class AdminOutlet < ::Thor

      desc 'stop', 'Stop the CASA engine'

      def stop
        pid = open(pid_file_path).read.strip.to_i
        Process.kill "HUP", pid
        FileUtils.rm_f pid_file_path
      rescue Errno::ENOENT
        say "The pid file #{pid_file_path} does not exist (Errno::ENOENT)", :red
        abort
      rescue Errno::ESRCH
        say "The process #{pid} does not exist (Errno::ESRCH)", :red
        FileUtils.rm_f pid_file_path
        abort
      rescue Errno::EPERM
        say "Lack of privileges to manage the process #{pid} (Errno::EPERM)", :red
        abort
      rescue ::Exception => e
        say "While signaling the PID, unexpected #{e.class}: #{e}", :red
        abort
      end

    end
  end
end
