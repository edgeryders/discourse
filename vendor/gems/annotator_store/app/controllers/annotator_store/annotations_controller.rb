require_dependency 'annotator_store/application_controller'

module AnnotatorStore
  class AnnotationsController < ApplicationController
    before_action :set_annotation, only: [:show, :update, :destroy]

    # POST /annotations
    def create
      format_client_input_to_rails_convention_for_create
      @annotation = Annotation.new(annotation_params)
      @annotation.creator = current_user
      respond_to do |format|
        if @annotation.save
          format.json {render :show, status: :created, location: annotation_url(@annotation)}
        else
          format.json {render json: @annotation.errors, status: :unprocessable_entity}
        end
      end
    end

    # GET /annotations/1
    def show
    end

    # PATCH/PUT /annotations/1
    def update
      format_client_input_to_rails_convention_for_update
      respond_to do |format|
        if @annotation.update(annotation_params)
          format.json {render :show, status: :ok, location: annotation_url(@annotation)}
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

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_annotation
      @annotation = Annotation.find(params[:id])
    end

    # Convert the data sent by AnnotatorJS to the format that Rails expects so
    # that we are able to create a proper params object
    def format_client_input_to_rails_convention_for_create
      params[:annotation] = {}
      params[:annotation][:version] = params[:annotator_schema_version] unless params[:annotator_schema_version].blank?
      params[:annotation][:text] = params[:text] #unless params[:text].blank?
      params[:annotation][:quote] = params[:quote] unless params[:quote].blank?
      params[:annotation][:uri] = params[:uri] unless params[:uri].blank?
      params[:annotation][:post_id] = params[:post] unless params[:post].blank?
      params[:annotation][:tag_id] = get_tag_id unless params[:tags].blank?
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
      params[:annotation] = {}
      params[:annotation][:version] = params[:annotator_schema_version] unless params[:annotator_schema_version].blank?
      params[:annotation][:text] = params[:text] #unless params[:text].blank?
      params[:annotation][:quote] = params[:quote] unless params[:quote].blank?
      params[:annotation][:tag_id] = params[:tags].present? ? get_tag_id : nil
      params[:annotation][:uri] = params[:uri] unless params[:uri].blank?
    end

    # Only allow a trusted parameter 'white list' through.
    def annotation_params
      params.require(:annotation).permit(
        :text,
        :quote,
        :uri,
        :version,
        :tag_id,
        :post_id,
        ranges_attributes: [:start, :end, :start_offset, :end_offset]
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


    private

    # If the path of the tag matches the given path.
    def path_matches?(tag, path)
      return true if tag.blank? && path.blank?

      if tag.present? && path.present? && tag.names.exists?(name: path.last)
        path_matches?(tag.parent, path.dup[0...-1])
      else
        false
      end
    end


  end
end
