require_dependency 'annotator_store/application_controller'

module AnnotatorStore
  class VideosController < ApplicationController


    def show
      @current_user = current_user
      @video = Upload.find(params[:id])
    end


  end
end
