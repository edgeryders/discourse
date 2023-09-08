module WebkitComponents
  class TopicsController < BaseController
    def show
      @topic = Topic.secured(guardian).includes(:posts).find(params[:id])

      render_serialized @topic, WebkitComponents::DiscussionSerializer
    end

    private

    def relevant_records
      Topic.distinct
           .listable_topics
           .secured(guardian)
           .includes(user: :user_profile)
           .left_outer_joins(:tags, :category)
           .yield_self { |r| params_for(:categories) ? r.where("categories.slug": params_for(:categories)) : r }
           .yield_self { |r| params_for(:tags) ? r.where("tags.name": params_for(:tags)) : r }
           .yield_self { |r| include_first_post? ? r.left_outer_joins(:first_post) : r }
    end

    def include_first_post?
      ["organizer", "event"].include?(params_for(:serializer).to_a.join)
    end
  end
end
