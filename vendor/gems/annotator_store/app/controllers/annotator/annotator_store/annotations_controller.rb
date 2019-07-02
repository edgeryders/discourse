require_dependency 'annotator/application_controller'

class Annotator::AnnotatorStore::AnnotationsController < Annotator::ApplicationController

  before_action :set_annotation, only: [:show, :update, :destroy]
  before_action :set_current_user, only: [:create, :show, :update, :destroy]


  def index
    scope = scoped_resource
    scope = scope.where(post_id: ::Topic.find(params[:topic_id]).try(:post_ids)) if params[:topic_id].present?
    scope = scope.where(post_id: params[:post_id]) if params[:post_id].present?
    scope = scope.where(creator_id: params[:creator_id]) if params[:creator_id].present?

    # Only annotations where the posts topics are tagged with the given discourse tag.
    if params[:discourse_tag].present?
      if (tag = ::Tag.find_by(name: params[:discourse_tag]))
        scope = scope.where(post_id: Post.where(topic_id: tag.topic_ids).ids)
      else
        scope = scope.none
      end
    end

    # Only annotations that are tagged with the given Open Ethnographer tag.
    scope = scope.where(tag_id: params[:code_id]) if params[:code_id].present?

    search_term = params[:search].to_s.strip
    resources = Administrate::Search.new(scope, dashboard_class, search_term).run
    resources = apply_resource_includes(resources)
    resources = order.apply(resources)
    resources = resources.page(params[:page]).per(records_per_page)
    page = Administrate::Page::Collection.new(dashboard, order: order)

    respond_to do |format|
      format.html {
        render locals: {
          resources: resources,
          search_term: search_term,
          page: page,
          show_search_bar: show_search_bar?
        }
      }
      format.json {
        # Rename tag_id to code_id
        r = resources.to_a.map(&:attributes).each {|a| a['code_id'] = a.delete('tag_id')}
        render json: JSON.pretty_generate(JSON.parse(r.to_json))
      }
    end
  end


  def records_per_page
    params[:per_page] || 100
  end


  # POST /annotations
  def create
    format_client_input_to_rails_convention_for_create
    # Determine the class based on the attributes that are set.
    @annotation = if params[:target].present?
                    AnnotatorStore::VideoAnnotation.new(annotation_params)
                  elsif params[:annotation][:geometry].present?
                    AnnotatorStore::ImageAnnotation.new(annotation_params)
                  else
                    AnnotatorStore::TextAnnotation.new(annotation_params)
                  end
    @annotation.creator = current_user
    respond_to do |format|
      if @annotation.save
        format.json {render :show, status: :created, location: annotator_annotator_store_annotations_url(@annotation)}
      else
        format.json {render json: @annotation.errors, status: :unprocessable_entity}
      end
    end
  end

  # GET /annotations/1
  def show
    respond_to do |format|
      format.html {render locals: { page: Administrate::Page::Show.new(dashboard, requested_resource) } }
      format.json {render :show}
    end
  end

  # PATCH/PUT /annotations/1
  def update
    format_client_input_to_rails_convention_for_update
    respond_to do |format|
      if @annotation.update(annotation_params)
        format.json {render :show, status: :ok, location: annotator_annotator_store_annotations_url(@annotation)}
      else
        format.json {render json: @annotation.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /annotations/1
  def destroy
    @annotation.destroy
    respond_to do |format|
      format.json {head :no_content, status: :no_content}
    end
  end

  # OPTIONS /annotations
  def options
    respond_to do |format|
      format.json {render :options}
    end
  end

  # Quick fix: Make the current user available in the json builder partial.
  def set_current_user
    @current_user = current_user
  end


  private

  # Convert the data sent by AnnotatorJS to the format that Rails expects so
  # that we are able to create a proper params object
  # VIDEO annotation input example:
  # {
  #   "uri"=>"/post/",
  #   "target"=>{
  #     "container"=>"vid1",
  #     "src"=>"http://vjs.zencdn.net/v/oceans.mp4",
  #     "ext"=>".mp4"
  #    },
  #   "rangeTime"=>{
  #     "start"=>11.560403,
  #     "end"=>16.2217363
  #   },
  #   "tags"=>["test", "tag", "→", "testtag", "deutsch"],
  #   "updated"=>"2019-06-19T19:39:59.349Z",
  #   "created"=>"2019-06-19T19:39:59.349Z",
  #   "text"=>"",
  #   "media"=>"video",
  #   "ranges"=>[],
  #   "quote"=>"",
  #   "annotator_schema_version"=>"v1.0",
  #   video_annotation"=>{"uri"=>"/post/1"}
  # }
  #
  # IMAGE annotation input example:
  # {
  #   "url": "http://lloydbleekcollection.cs.uct.ac.za/images/stow/STOW_001.JPG",
  #   "text": "sdfdfasdf",
  #   "ranges": [],
  #   "quote": "",
  #   "closure_uid_k7l337": 6,
  #   "l": [
  #     {
  #       "type": "rect",
  #       "a": {
  #         "x": 314,
  #         "width": 261,
  #         "y": 207,
  #         "height": 188
  #       }
  #     }
  #   ]
  # }
  def format_client_input_to_rails_convention_for_create
    params[:annotation] = {}
    params[:annotation][:tag_id] = get_tag_id unless params[:tags].blank?

    # VideoAnnotation
    params[:annotation][:uri] = params[:uri] unless params[:uri].blank?
    params[:annotation][:container] = params[:target][:container] unless params[:target].blank?
    params[:annotation][:src] = params[:target][:src] unless params[:target].blank?
    params[:annotation][:ext] = params[:target][:ext] unless params[:target].blank?
    params[:annotation][:start] = params[:rangeTime][:start] unless params[:rangeTime].blank?
    params[:annotation][:end] = params[:rangeTime][:end] unless params[:rangeTime].blank?

    # ImageAnnotation
    # params[:annotation][:page_url] = params[:page_url] unless params[:page_url].blank?
    params[:annotation][:src] = params[:url] unless params[:url].blank?
    params[:annotation][:units] = 'pixel'
    params[:annotation][:shape] = params[:l][0][:type] unless params[:l].blank?
    params[:annotation][:geometry] = params[:l][0][:a].to_json.to_s unless params[:l].blank?

    # TextAnnotation
    params[:annotation][:version] = params[:annotator_schema_version] unless params[:annotator_schema_version].blank?
    params[:annotation][:text] = params[:text] #unless params[:text].blank?
    params[:annotation][:quote] = params[:quote] unless params[:quote].blank?
    params[:annotation][:uri] = params[:uri] unless params[:uri].blank?
    params[:annotation][:post_id] = params[:uri].split('/').last unless params[:uri].blank?
    params[:annotation][:ranges_attributes] = params[:ranges].map do |r|
      range = {}
      range[:start] = r[:start]
      range[:end] = r[:end]
      range[:start_offset] = r[:startOffset]
      range[:end_offset] = r[:endOffset]
      range
    end unless params[:ranges].blank?
  end

  # Convert the data sent by AnnotatorJS to the format that Rails expects so
  # that we are able to create a proper params object
  def format_client_input_to_rails_convention_for_update
    format_client_input_to_rails_convention_for_create
  end

  # Only allow a trusted parameter 'white list' through.
  def annotation_params
    params.require(:annotation).permit(
      :tag_id, :uri,
      # VideoAnnotation
      :container, :src, :ext, :start, :end,
      # Image Annotation
      :src, :shape, :units, :geometry,
      # TextAnnotation
      :text, :quote, :version, :post_id, ranges_attributes: [:start, :end, :start_offset, :end_offset]
    )
  end

  def get_tag_id
    path = params[:tags].join(' ').split(' → ').map(&:strip)
    language = AnnotatorStore::UserSetting.language_for_user(current_user)
    tag_names = AnnotatorStore::TagName.joins(:tag).where(name: path.last, annotator_store_tags: {creator_id: current_user.id}).all

    if tag_names.blank?
      tag = AnnotatorStore::Tag.new(creator: current_user)
      tag.names.build(name: path.last, language: language)
      tag.save!
      return tag.id
    else
      tag_names.each do |tag_name|
        return tag_name.tag_id if path_matches?(tag_name.tag, path)
      end
    end
  end

  # If the path of the tag matches the given path.
  def path_matches?(tag, path)
    return true if tag.blank? && path.blank?

    if tag.present? && path.present? && tag.names.exists?(name: path.last)
      path_matches?(tag.parent, path.dup[0...-1])
    else
      false
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_annotation
    @annotation = AnnotatorStore::Annotation.find(params[:id])
  end


  # disable 'edit' and 'destroy' links
  def valid_action?(name, resource = resource_class)
    %w[edit destroy].exclude?(name.to_s) && super
  end



end
