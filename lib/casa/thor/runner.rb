require 'thor'
require 'casa/thor/admin_outlet'
require 'casa/thor/engine'

module CASA
  module Thor
    class Runner < ::Thor

      register ::CASA::Thor::Engine, :engine, "engine", "CASA engine"
      register ::CASA::Thor::AdminOutlet, :admin_outlet, "admin_outlet", "CASA admin outlet"

    end
  end
end