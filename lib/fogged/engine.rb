module Fogged
  class Engine < ::Rails::Engine
    isolate_namespace Fogged
    config.fogged = Fogged
  end
end
