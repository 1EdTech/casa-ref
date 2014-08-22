require 'thor'
require 'casa/thor/admin_outlet'
require 'casa/thor/engine'
require 'casa/thor/server'

module CASA
  module Thor
    class Runner < ::Thor

      register ::CASA::Thor::Engine, :engine, "engine", "CASA engine"
      register ::CASA::Thor::AdminOutlet, :admin_outlet, "admin_outlet", "CASA admin outlet"
      register ::CASA::Thor::Server, :server, "server", "Server running CASA"

    end
  end
end