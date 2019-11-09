# name: EdgerydersMultisiteAccounts
# about:
# version: 0.1
# authors: damingo
# url: https://github.com/damingo

require 'discourse_api'
require 'securerandom'

register_asset "stylesheets/common/edgeryders-multisite-accounts.scss"

enabled_site_setting :edgeryders_multisite_accounts_enabled

PLUGIN_NAME ||= "EdgerydersMultisiteAccounts".freeze


after_initialize do


  # see lib/plugin/instance.rb for the methods available in this context
  module ::EdgerydersMultisiteAccounts
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace EdgerydersMultisiteAccounts
    end
  end


  require_dependency "application_controller"
  class EdgerydersMultisiteAccounts::ActionsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    skip_before_action :redirect_to_login_if_required

    # See: https://edgeryders.eu/t/it-development-plan-for-the-h2020-projects/9202#heading--2-2-posting
    def create
      return render_json_error("Not allowed.") unless SiteSetting.enable_sso_provider
      unless params[:auth_key].present? && params[:auth_key] == Rails.application.secrets.auth_key
        return render_json_error("auth_key: Is invalid.")
      end
      return render_json_error("accepted_gtc: GTCs must be accepted.") unless !!params[:accepted_gtc]
      return render_json_error("accepted_privacy_policy: Privacy policy must be accepted.") unless !!params[:accepted_privacy_policy]
      if params[:requested_api_keys].blank?
        return render_json_error("requested_api_keys: At least one domain name is required. Separate multiple domain names by whitespace.")
      end
      if params[:edgeryders_research_consent].present? && !params[:edgeryders_research_consent]
        return render_json_error("edgeryders_research_consent: Edgeryders research consent is required.")
      end
      response = create_sso_provider_account
      return render json: response, status: :unprocessable_entity unless response['success']
      sso_provider_user = User.find_by(username: params[:username])
      api_keys = params[:requested_api_keys].split(' ').map do |hostname|
        create_community_account(hostname: hostname, sso_provider_user: sso_provider_user)
      end
      respond_to do |format|
        format.json do
          render json: {
            success: true,
            id: sso_provider_user.id,
            username: sso_provider_user.username,
            email: sso_provider_user.email,
            active: sso_provider_user.active,
            created_at: sso_provider_user.created_at,
            username_lower: sso_provider_user.username_lower,
            trust_level: sso_provider_user.trust_level,
            api_keys: api_keys
          }.to_json
        end
      end
    end


    private

    def create_sso_provider_account
      hostname = Rails.application.secrets.sso_provider[:hostname]
      api_key = Rails.application.secrets.sso_provider[:api_key]
      client = DiscourseApi::Client.new("#{protocol}://#{hostname}?api_key=#{api_key}&api_username=system")
      client.create_user(
        name: params[:username],
        email: params[:email],
        username: params[:username],
        password: params[:password]
      )
    end


    # Doc: https://meta.discourse.org/t/sync-sso-user-data-with-the-sync-sso-route/84398
    # hostname: Hostname of the forum where the user shall be created.
    # sso_provider_user: Reference user on the SSO provider site.
    # @return
    #   {site: "edgeryders.eu", key: "sgev47…fdffd0"}
    def create_community_account(args = {})
      # NOTE: Do not use `client.api_key= ...` as this supplies the API key in the header. As of now (2019-09-21)
      # this only works with the discourse master branch, but we are on the stable branch.
      # See: https://github.com/discourse/discourse/blob/master/lib/auth/default_current_user_provider.rb
      api_key = Rails.application.secrets.communities.find {|i| i[:hostname] == args[:hostname]}[:api_key]
      client = DiscourseApi::Client.new("#{protocol}://#{args[:hostname]}?api_key=#{api_key}&api_username=system")
      create_user_response = client.sync_sso(
        name: args[:sso_provider_user].name,
        sso_secret: SiteSetting.sso_secret,
        username: args[:sso_provider_user].username,
        email: args[:sso_provider_user].email,
        external_id: args[:sso_provider_user].id
      )
      user = client.by_external_id(args[:sso_provider_user].id)
      api_key_response = client.generate_user_api_key(user['id'])

      {site: args[:hostname], key: api_key_response['api_key']['key']}
    end


    def protocol
      Rails.env.production? ? 'https' : 'http'
    end
  end


  EdgerydersMultisiteAccounts::Engine.routes.draw do
    get "/multisite_account(.:format)" => "actions#create", format: :json
  end


  Discourse::Application.routes.append do
    mount ::EdgerydersMultisiteAccounts::Engine, at: ''
  end


end
