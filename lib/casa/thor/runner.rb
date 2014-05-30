require 'thor'
require 'casa/thor/admin_outlet'
require 'casa/thor/engine'

module Casa
  module Thor
    class Runner < ::Thor

      register ::Casa::Thor::Engine, :engine, "engine", "CASA engine"
      register ::Casa::Thor::AdminOutlet, :admin_outlet, "admin_outlet", "CASA admin outlet"

    end
  end
end