# All Administrate controllers inherit from this `Admin::ApplicationController`,
# making it the ideal place to put authentication logic or other
# before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
class Administration::ApplicationController < Administrate::ApplicationController

  helper :administration
  include ::CurrentUser

  before_action :ensure_logged_in
  before_action :ensure_staff


  def namespace
    'administration_annotator_store'
  end


  # This is the API for the ethical consent funnel
  # https://edgeryders.eu/t/using-the-edgeryders-eu-apis/7904#heading--3
  # Accessible as: /administration/annotator/users.json
  def consent
    users = User.where(active: true).joins("LEFT JOIN user_custom_fields ON user_custom_fields.user_id = users.id AND user_custom_fields.name = 'edgeryders_consent'").select('users.id, users.username, user_custom_fields.value as edgeryders_consent').order('users.id ASC')

    user_data = users.map {|u| {id: u.id, username: u.username, edgeryders_consent: u.edgeryders_consent} }

    respond_to do |format|
      format.json { render json: JSON.pretty_generate(user_data) }
    end
  end





  private

  def ensure_logged_in
    raise Discourse::NotLoggedIn.new unless current_user.present?
  end

  def ensure_staff
    raise Discourse::InvalidAccess.new unless current_user && current_user.staff?
  end

  def ensure_admin
    raise Discourse::InvalidAccess.new unless current_user && current_user.admin?
  end


end
