# frozen_string_literal: true

class EdgerydersApiUserMailer < ActionMailer::Base
  include Email::BuildEmailHelper

  def send_email(to_address, username)
    build_email(
      to_address,
      template: "user_notifications.edgeryders_api_account_created",
      username: username,
      email: to_address,
      )
  end
end
