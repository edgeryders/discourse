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

    # user: User object on the SSO provider site.
    # hostname: Hostname of the forum for which to get the API key.
    # @return: API key
    def self.get_community_account_api_key(args={})
      community_config = Rails.application.secrets.communities.find {|i| i[:hostname] == args[:hostname]}
      raise ArgumentError.new("The master API key for #{args[:hostname]} is not available.") unless community_config.present?
      master_api_key = community_config[:api_key]
      client = DiscourseApi::Client.new("#{protocol}://#{args[:hostname]}?api_key=#{master_api_key}&api_username=system")

      begin
        client_user = client.by_external_id(args[:user].id)
        # NOTE: Only the admin API includes the users API key in the response.
        client_user_details = client.get("/admin/users/#{client_user['id']}.json")[:body]

        if client_user_details['api_key'].present?
          client_user_details['api_key']['key']
        else
          api_key_response = client.generate_user_api_key(client_user['id'])
          api_key_response['api_key']['key']
        end
      rescue DiscourseApi::NotFoundError => e
        create_community_account(hostname: args[:hostname], sso_provider_user: args[:user])['key']
      end
    end


    # username:
    # email:
    # password:
    def self.create_sso_provider_account(args={})
      hostname = Rails.application.secrets.sso_provider[:hostname]
      api_key = Rails.application.secrets.sso_provider[:api_key]
      client = DiscourseApi::Client.new("#{EdgerydersMultisiteAccounts.protocol}://#{hostname}?api_key=#{api_key}&api_username=system")
      client.create_user(
        name: args[:username],
        email: args[:email],
        username: args[:username],
        password: args[:password]
      )
    end


    # Doc: https://meta.discourse.org/t/sync-sso-user-data-with-the-sync-sso-route/84398
    # hostname: Hostname of the forum where the user shall be created.
    # sso_provider_user: Reference user on the SSO provider site.
    # @return
    #   {site: "edgeryders.eu", key: "sgev47…fdffd0"}
    def self.create_community_account(args = {})
      # NOTE: Do not use `client.api_key= ...` as this supplies the API key in the header. As of now (2019-09-21)
      # this only works with the discourse master branch, but we are on the stable branch.
      # See: https://github.com/discourse/discourse/blob/master/lib/auth/default_current_user_provider.rb
      api_key = Rails.application.secrets.communities.find {|i| i[:hostname] == args[:hostname]}[:api_key]
      client = DiscourseApi::Client.new("#{EdgerydersMultisiteAccounts.protocol}://#{args[:hostname]}?api_key=#{api_key}&api_username=system")

      sync_sso_args = {
        name: args[:sso_provider_user].name,
        sso_secret: SiteSetting.sso_secret,
        username: args[:sso_provider_user].username,
        email: args[:sso_provider_user].email,
        external_id: args[:sso_provider_user].id
      }
      sync_sso_args[:'custom.edgeryders_consent'] = '1' if args[:edgeryders_research_consent].present?

      create_user_response = client.sync_sso(**sync_sso_args)
      user = client.by_external_id(args[:sso_provider_user].id)
      api_key_response = client.generate_user_api_key(user['id'])

      {site: args[:hostname], key: api_key_response['api_key']['key']}
    end

    def self.protocol
      Rails.env.production? ? 'https' : 'http'
    end

  end



  require_dependency "application_controller"
  class EdgerydersMultisiteAccounts::ActionsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    before_action :ensure_logged_in, except: [:create]


    # See: https://edgeryders.eu/t/it-development-plan-for-the-h2020-projects/9202#heading--2-2-posting
    def create
      return render_json_error("Not allowed.") unless SiteSetting.enable_sso_provider
      unless params[:auth_key].present? && params[:auth_key] == Rails.application.secrets.auth_key
        return render_json_error("auth_key: Is invalid.")
      end
      return render_json_error("accepted_gtc: GTCs must be accepted.") unless params[:accepted_gtc] == 'true'
      return render_json_error("accepted_privacy_policy: Privacy policy must be accepted.") unless params[:accepted_privacy_policy] == 'true'
      if params[:requested_api_keys].blank?
        return render_json_error("requested_api_keys: At least one domain name is required. Separate multiple domain names by whitespace.")
      end
      if params[:edgeryders_research_consent].present? && params[:edgeryders_research_consent] != 'true'
        return render_json_error("edgeryders_research_consent: Edgeryders research consent is required.")
      end
      response = EdgerydersMultisiteAccounts.create_sso_provider_account(
          username: params[:username],
          email: params[:email],
          password: params[:password]
      )
      return render json: response, status: :unprocessable_entity unless response['success']
      sso_provider_user = User.find_by(username: params[:username])
      api_keys = params[:requested_api_keys].split(' ').map do |hostname|
        EdgerydersMultisiteAccounts.create_community_account(
          hostname: hostname,
          sso_provider_user: sso_provider_user,
          edgeryders_research_consent: params[:edgeryders_research_consent]
        )
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


    # @return The current users API key for the community site provided as params[:hostname]
    def get_api_key
      render json: EdgerydersMultisiteAccounts.get_community_account_api_key(user: current_user, hostname: params[:hostname])
    end

  end


  EdgerydersMultisiteAccounts::Engine.routes.draw do
    get "/multisite_account(.:format)" => "actions#create", format: :json
    get "/multisite_account_api_key(.:format)" => "actions#get_api_key", format: :json
  end


  Discourse::Application.routes.append do
    mount ::EdgerydersMultisiteAccounts::Engine, at: ''
  end


end
