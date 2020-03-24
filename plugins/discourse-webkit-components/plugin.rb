# name: discourse-webkit-components
# about: Expose data source for edgeryders webkit components
# version: 0.1.0
# authors: James Kiesel (gdpelican)
# url: https://github.com/edgeryders/discourse-webkit-components

after_initialize do
  module ::WebkitComponents
    class Engine < ::Rails::Engine
      engine_name "discourse-webkit-components"
      isolate_namespace WebkitComponents

      [
        "../controllers/base_controller",
        "../controllers/categories_controller",
        "../controllers/topics_controller",
        "../controllers/users_controller",
        "../serializers/category_serializer",
        "../serializers/topic_serializer",
        "../serializers/post_serializer",
        "../serializers/discussion_serializer",
        "../serializers/organizer_serializer",
        "../serializers/event_serializer",
        "../serializers/user_serializer"
      ].each { |path| require File.expand_path(path, __FILE__) }

      routes.draw do
        resources :categories, only: :index, format: :json
        resources :topics, only: [:show, :index], format: :json
        resources :users, only: :index, format: :json
      end
    end
  end

  Discourse::Application.routes.append do
    mount ::WebkitComponents::Engine, at: '/webkit_components'
  end
end
