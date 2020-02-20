module WebkitComponents
  class TopicsController < BaseController
    private

    def relevant_records
      Topic.distinct
           .listable_topics
           .secured(guardian)
           .includes(user: :user_profile)
           .left_outer_joins(:tags, :category)
           .yield_self { |r| params_for(:categories) ? r.where("categories.slug": params_for(:categories)) : r }
           .yield_self { |r| params_for(:tags) ? r.where("tags.name": params_for(:tags)) : r }
           .yield_self { |r| params_for(:serializer).to_a.join == "organizer" ? r.left_outer_joins(:first_post) : r }
    end
  end
end
