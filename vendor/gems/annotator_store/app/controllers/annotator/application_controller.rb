# https://github.com/thoughtbot/administrate/blob/master/app/controllers/administrate/application_controller.rb

class Annotator::ApplicationController < Administrate::ApplicationController
  include ::CurrentUser

  protect_from_forgery prepend: true

  before_action :ensure_logged_in
  before_action :ensure_staff_or_annotator_group_member
  before_action :set_headers


  def front
  end


  def namespace
    'annotator_annotator_store'
  end



  private

  def set_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Expose-Headers'] = 'ETag'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PATCH, PUT, DELETE, OPTIONS, HEAD'
    headers['Access-Control-Allow-Headers'] = '*,x-requested-with,Content-Type,If-Modified-Since,If-None-Match'
    headers['Access-Control-Max-Age'] = '86400'
  end

  def ensure_logged_in
    raise Discourse::NotLoggedIn.new unless current_user.present?
  end

  def ensure_staff
    raise Discourse::InvalidAccess.new unless current_user && current_user.staff?
  end

  def ensure_admin
    raise Discourse::InvalidAccess.new unless current_user && current_user.admin?
  end

  def ensure_staff_or_annotator_group_member
    raise Discourse::InvalidAccess.new unless current_user && (current_user.staff? || current_user.groups.pluck(:name).map(&:downcase).include?('annotator'))
  end


end
