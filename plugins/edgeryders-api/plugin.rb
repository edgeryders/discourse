# name: edgeryders-api
# about:
# version: 0.1
# authors: Edgeryders
# url: https://github.com/edgeryders

require 'discourse_api'
require 'securerandom'

register_asset "stylesheets/common/edgeryders-api.scss"

enabled_site_setting :edgeryders_api_enabled

PLUGIN_NAME ||= "edgeryders-api".freeze

after_initialize do
  %w(
    ../app/jobs/edgeryders_api/regular/account_created_email.rb
    ../app/mailers/edgeryders_api/user_mailer.rb
  ).each do |path|
    load File.expand_path(path, __FILE__)
  end

  module ::EdgerydersApi
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace EdgerydersApi
    end

    # username:
    # email:
    # password:
    def self.create_account(args = {})
      client = DiscourseApi::Client.new("#{protocol}://#{SiteSetting.edgeryders_api_host}", SiteSetting.edgeryders_api_system_user_api_key, "system")

      attributes = {
        name: args[:username],
        email: args[:email],
        active: true,
        username: args[:username],
        password: args[:password]
      }
      response = client.create_user(attributes)
      if response['success']
        Jobs.enqueue(Jobs::EdgerydersApi::AccountCreatedEmail, {
          to_address: args[:email],
          username: args[:username]
        })
      end

      response
    end

    def self.protocol
      Rails.env.production? ? 'https' : 'http'
    end

    # TODO Adapt when fixed
    # See: https://meta.discourse.org/t/404-error-returned-when-using-discourseapi-gem-to-generate-user-api-key/140892
    def self.create_user_api_key(username)
      require 'net/http'
      require 'json'
      uri = URI.parse "#{protocol}://#{SiteSetting.edgeryders_api_host}/admin/api/keys"
      http = Net::HTTP.new(uri.host, uri.port)
      if protocol == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request = Net::HTTP::Post.new(uri.request_uri)
      request.initialize_http_header(
        {
          "Content-type" => "application/json",
          "Api-Key" => "#{SiteSetting.edgeryders_api_system_user_api_key}",
          "Api-Username" => "system",
          'Cache-Control' => "no-cache"
        })
      request.set_form_data('key[username]' => username)
      response = http.request(request)
      JSON.parse(response.body)['key']['key']
    end

  end

  require_dependency "application_controller"

  class EdgerydersApi::ActionsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    before_action :redirect_to_login_if_required, except: [:create]
    before_action :ensure_logged_in, except: [:create]

    # https://edgeryders.eu/t/using-the-edgeryders-eu-apis/7904
    # https://edgeryders.eu/t/it-development-plan-for-the-h2020-projects/9202#heading--2-2-posting
    def create
      unless params[:auth_key].present? && params[:auth_key] == SiteSetting.edgeryders_api_auth_key
        return render_json_error("auth_key: Is invalid.")
      end
      return render_json_error("accepted_gtc: GTCs must be accepted.") unless params[:accepted_gtc] == 'true'
      return render_json_error("accepted_privacy_policy: Privacy policy must be accepted.") unless params[:accepted_privacy_policy] == 'true'
      if params[:requested_api_keys].blank?
        return render_json_error("requested_api_keys: At least one domain name is required. Separate multiple domain names by whitespace.")
      end
      unless params[:edgeryders_research_consent] == 'true'
        return render_json_error("edgeryders_research_consent: Edgeryders research consent is required.")
      end

      response = EdgerydersApi.create_account(
        username: params[:username],
        email: params[:email],
        password: params[:password]
      )
      return render json: response, status: :unprocessable_entity unless response['success']

      user = User.find_by(username: params[:username])
      user.custom_fields['edgeryders_consent'] = '1'
      user.save!

      key = EdgerydersApi.create_user_api_key(user.username)

      respond_to do |format|
        format.json do
          render json: {
            success: true,
            id: user.id,
            username: user.username,
            email: user.email,
            active: user.active,
            created_at: user.created_at,
            username_lower: user.username_lower,
            trust_level: user.trust_level,
            api_keys: [
              { site: 'edgeryders.eu', key: key }
            ]
          }.to_json
        end
      end
    end

  end

  EdgerydersApi::Engine.routes.draw do
    get "/multisite_account(.:format)" => "actions#create", format: :json
  end

  Discourse::Application.routes.append do
    mount ::EdgerydersApi::Engine, at: ''
  end

end



