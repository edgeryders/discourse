# frozen_string_literal: true

# name: edgeryders-permit-api-cors
# about: Allow CORS to accept Api-Key and Api-Username headers
# version: 0.1
# authors: James Kiesel (gdpelican)
# url: https://github.com/gdpelican/permit-api-cors

after_initialize do
  class ::Discourse::Cors
    module AllowApiKey
      HEADER_KEY = 'Access-Control-Allow-Headers'
      HEADER_VALUES = ['Api-Key', 'Api-Username']

      def apply_headers(cors_origins, env, headers)
        result = super(cors_origins, env, headers)
        result[HEADER_KEY] = result[HEADER_KEY].split(', ').concat(HEADER_VALUES).join(', ') if cors_origins.presence
        result
      end
    end
    singleton_class.prepend AllowApiKey
  end


  require_dependency "application_controller"
  class ::PostsController < ApplicationController
    skip_before_action :verify_authenticity_token, only: :create
    before_action :verify_authenticity_token, only: :create, if: :is_api?
  end


end
