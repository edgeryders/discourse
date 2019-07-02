require_dependency 'annotator/application_controller'

class Annotator::VideosController < Annotator::ApplicationController



  def show
    @current_user = current_user
    if (upload = Upload.find_by(id: params[:id]))
      @video_id = upload.id
      @video_src = upload.url
    else
      @video_id = params[:id]
      @video_src = params[:src]
    end
  end


  def namespace
    'annotator'
  end


end
