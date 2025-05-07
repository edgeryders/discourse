module WebkitComponents
  class UsersController < BaseController
    private

    def relevant_records
      User.includes(:user_profile)
          .where.not(id: Discourse.system_user.id)
          .order(last_posted_at: :desc)
          .yield_self { |r| params_for(:categories) ? r.joins(category_users: :category).where("categories.slug": params_for(:categories)) : r }
          .yield_self { |r| params_for(:topics) ? r.joins(:topic_users).where("topic_users.topic_id": params_for(:topics)) : r }
    end
  end
end
