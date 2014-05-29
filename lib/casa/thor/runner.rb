require 'thor'
require 'casa/thor/engine'

module Casa
  module Thor
    class Runner < ::Thor

      register ::Casa::Thor::Engine, :engine, "engine", "CASA engine controller"

    end
  end
end