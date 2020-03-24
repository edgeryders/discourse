module WebkitComponents
  class DiscussionSerializer < TopicSerializer
    attribute :posts

    def posts
      ActiveModel::ArraySerializer.new(
        object.posts.reject(&:is_first_post?),
        each_serializer: WebkitComponents::PostSerializer,
        scope: scope
      )
    end
  end
end
