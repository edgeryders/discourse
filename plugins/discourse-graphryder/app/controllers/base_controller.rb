module Graphryder
  class BaseController < ApplicationController
    before_action :ensure_graphryder

    def query
      render json: Graphryder::Query.instance.perform(params[:query])
    end

    private

    def ensure_graphryder
      raise Discourse::InvalidAccess.new unless current_user&.is_annotator?
    end
  end
end
