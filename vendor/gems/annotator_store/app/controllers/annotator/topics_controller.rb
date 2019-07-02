require_dependency 'annotator/application_controller'

class Annotator::TopicsController < Annotator::ApplicationController


  # def index
  #   search_term = params[:search].to_s.strip
  #   resources = Administrate::Search.new(scoped_resource, dashboard_class, search_term).run
  #   resources = apply_resource_includes(resources)
  #   resources = order.apply(resources)
  #   resources = resources.page(params[:page]).per(records_per_page)
  #   page = Administrate::Page::Collection.new(dashboard, order: order)
  #
  #   render locals: {
  #     resources: resources,
  #     search_term: search_term,
  #     page: page,
  #     show_search_bar: show_search_bar?,
  #   }
  # end


  def show
    opts = params.slice(:username_filters, :filter, :page, :post_number, :show_deleted)
    page = params[:page]&.to_i

    @current_user = current_user
    @topic_view = TopicView.new(params[:id] || params[:topic_id], current_user, opts)

    if page.present? && ((page < 0) || ((page - 1) * @topic_view.chunk_size > @topic_view.topic.highest_post_number))
      raise Discourse::NotFound
    end
  end


  # disable 'edit' and 'destroy' links
  def valid_action?(name, resource = resource_class)
    %w[edit destroy].exclude?(name.to_s) && super
  end


  def namespace
    'annotator'
  end


  def show_search_bar?
    true
  end

  # # Override this if you have certain roles that require a subset
  # # this will be used to set the records shown on the `index` action.
  def scoped_resource
    scope = Topic.all_with_annotations
    scope = scope.where(annotator_store_annotations: {creator_id: params[:annotator_id]}) if params[:annotator_id].present?
    scope
  end

  def records_per_page
    params[:per_page] || 50
  end


end
