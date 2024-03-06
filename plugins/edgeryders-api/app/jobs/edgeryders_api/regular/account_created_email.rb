# frozen_string_literal: true

module Jobs
  class EdgerydersApiAccountCreatedEmail < ::Jobs::Base
    sidekiq_options queue: "critical"

    def execute(args)
      to_address = args[:to_address]
      username = args[:username]

      raise Discourse::InvalidParameters.new(:to_address) if to_address.blank?
      raise Discourse::InvalidParameters.new(:username) if username.blank?

      message = EdgerydersApiUserMailer.send_email(to_address, username)
      Email::Sender.new(message, :edgeryders_api_account_created_message).send
    end
  end

end
