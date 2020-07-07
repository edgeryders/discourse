# name: discourse-graphryder
# about: RedisGraph integration for Discourse
# version: 0.1.0
# authors: James Kiesel (gdpelican)
# url: https://github.com/gdpelican/discourse-graphryder

after_initialize do
  module ::Graphryder
    class Engine < ::Rails::Engine
      engine_name 'graphryder'
      isolate_namespace Graphryder

      if !Discourse.redis.call('module', 'list').find { |_, name, _, _| name == 'graph' }
        if Rails.env.development? && false
          puts "Installing local redisgraph for development..."
          path = File.expand_path File.dirname(__dir__)
          Discourse.redis.call(
            'module',
            'load',
            "#{path}/discourse-graphryder/redisgraph.so"
          )
        else
          warn [
            "Redis does not have RedisGraph installed as a module,",
            "please install it before using the discourse-graphryder plugin."
          ].join("\n")
        end
      end


      def self.require_path(path)
        require Rails.root.join('plugins', 'discourse-graphryder', 'app', path).to_s
      end

      require_path 'models/query'
      require_path 'controllers/base_controller'
      require_path 'services/importer'
      require_path 'services/initializer'
      require_path 'services/updater'

      routes.draw { post "query" => "base#query", format: :json }
    end
  end

  Discourse::Application.routes.append do
    mount ::Graphryder::Engine, at: '/graphryder', as: :graphryder
  end

  Graphryder::Initializer.initialize!
end
