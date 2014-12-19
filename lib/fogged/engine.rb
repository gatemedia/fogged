module Fogged
  class Engine < ::Rails::Engine
    isolate_namespace Fogged
    config.fogged = Fogged

    initializer "fogged.detect_zencoder" do
      if defined?(Zencoder) && defined?(Delayed::Job)
        Fogged.zencoder_enabled = true
      end
    end
  end
end
