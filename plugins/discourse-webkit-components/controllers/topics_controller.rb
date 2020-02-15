module WebkitComponents
  class TopicsController < BaseController
    private

    def relevant_records
      Topic.distinct
           .secured(guardian)
           .includes(user: :user_profile)
           .left_outer_joins(:tags, :category)
           .yield_self { |r| params_for(:categories) ? r.where("categories.slug": params_for(:categories)) : r }
           .yield_self { |r| params_for(:tags) ? r.where("tags.name": params_for(:tags)) : r }
    end
  end
end
