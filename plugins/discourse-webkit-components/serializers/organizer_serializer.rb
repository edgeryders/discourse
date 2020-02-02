module WebkitComponents
  class OrganizerSerializer < TopicSerializer
    attribute :username

    def username
      object.excerpt.to_s.match(/(@[^\s]*(?=<\/a>))/)
    end

    def include_views?
      false
    end

    def include_reply_count?
      false
    end

    def include_like_count?
      false
    end

    def include_author?
      false
    end
  end
end
