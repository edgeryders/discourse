module WebkitComponents
  class TopicSerializer < ActiveModel::Serializer
    attributes :id,
               :title,
               :excerpt,
               :url,
               :image_url,
               :views,
               :reply_count,
               :like_count,
               :created_at,
               :bumped_at,
               :author

    def excerpt
      object.excerpt.to_s
            .gsub(/(<([^>]+)>)/i, "")
            .gsub(/\s*\[.*?\]\s*/, "")
            .gsub(/(\r\n|\n|\r|\\n)/m, "")
            .gsub(/(\r\n|\n|\r|\\n)/m, "")
            .gsub("&hellip;", "...")
            .gsub("&amp", "&");
    end

    def author
      UserSerializer.new(object.user, root: false).as_json
    end
  end
end
