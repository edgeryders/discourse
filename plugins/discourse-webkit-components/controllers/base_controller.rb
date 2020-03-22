module WebkitComponents
  class BaseController < ApplicationController
    def index
      render_serialized records_to_serialize, serializer
    end

    private

    def records_to_serialize
      relevant_records.limit(params.fetch(:per, 50)).offset(params.fetch(:from, 0))
    end

    def relevant_records
      raise NotImplementedError.new
    end

    def serializer
      "WebkitComponents::#{serializer_param.humanize.singularize}Serializer".constantize
    end

    def serializer_param
      %w(category event organizer topic user).detect { |s| s == params[:serializer] } || controller_name
    end

    def params_for(param)
      params.fetch(param, '').split(',').presence
    end
  end
end
