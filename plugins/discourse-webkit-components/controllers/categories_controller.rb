module WebkitComponents
  class CategoriesController < BaseController
    private

    def relevant_records
      Category.where.not(slug: ENV['WEBKIT_EXCLUDED_CATEGORIES'].to_s.split(','))
              .where.not(description: nil)
              .joins(:latest_post)
              .order("posts.created_at": :desc)
    end
  end
end
