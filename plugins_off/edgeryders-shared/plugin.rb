# name: EdgerydersShared
# about:
# version: 0.1
# authors: damingo
# url: https://github.com/damingo


register_asset "stylesheets/common/edgeryders-shared.scss"


enabled_site_setting :edgeryders_shared_enabled

PLUGIN_NAME ||= "EdgerydersShared".freeze

after_initialize do
  # see lib/plugin/instance.rb for the methods available in this context



  require_dependency 'current_user_serializer'
  class ::CurrentUserSerializer
    attributes :annotator

    def annotator
      object.groups.exists?(name: 'annotator')
    end
  end




  module ::EdgerydersShared
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace EdgerydersShared
    end
  end

  

  
  require_dependency "application_controller"
  class EdgerydersShared::ActionsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    before_action :ensure_logged_in

    def list
      render json: success_json
    end
  end

  EdgerydersShared::Engine.routes.draw do
    get "/list" => "actions#list"
  end

  Discourse::Application.routes.append do
    mount ::EdgerydersShared::Engine, at: "/edgeryders-shared"
  end
  
end
