require_dependency 'annotator_store/application_controller'

module AnnotatorStore
  class TopicsController < ApplicationController


    def show
      opts = params.slice(:username_filters, :filter, :page, :post_number, :show_deleted)
      page = params[:page]

      @current_user = current_user
      @topic_view = TopicView.new(params[:id] || params[:topic_id], current_user, opts)

      if page.present? && ((page < 0) || ((page - 1) * @topic_view.chunk_size > @topic_view.topic.highest_post_number))
        raise Discourse::NotFound
      end
    end


  end
end
