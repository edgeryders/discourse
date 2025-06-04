module WebkitComponents
  class PostSerializer < BasicPostSerializer
    attributes :excerpt, :avatar_url

    def excerpt
      object.excerpt(200)
    end

    def avatar_url
      Discourse.base_url + object.user.avatar_template.sub('{size}', '200')
    end

    def include_avatar_template?
      false
    end
  end
end
