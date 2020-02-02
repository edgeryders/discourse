module WebkitComponents
  class UsersController < BaseController
    private

    def relevant_records
      User.includes(:user_profile)
          .where.not(id: Discourse.system_user.id)
          .order(last_posted_at: :desc)
    end
  end
end
