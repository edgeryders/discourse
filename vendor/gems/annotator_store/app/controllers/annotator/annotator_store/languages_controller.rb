require_dependency 'annotator/application_controller'


class Annotator::AnnotatorStore::LanguagesController < Annotator::ApplicationController


  def index
    search_term = params[:search].to_s.strip
    resources = Administrate::Search.new(scoped_resource, dashboard_class, search_term).run
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
          show_search_bar: show_search_bar?,
        }
      }
      format.json {
        render json: JSON.pretty_generate(JSON.parse(resources.to_json))
      }
    end
  end


  # Define a custom finder by overriding the `find_resource` method:
  # def find_resource(param)
  #   Language.find_by!(slug: param)
  # end

  # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
  # for more information

end
