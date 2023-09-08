module WebkitComponents
  class EventSerializer < TopicSerializer
    attributes :event, :location, :date, :event_type, :confirmed, :tags, :cooked, :raw

    def location
      from_event_tag :location, length: 15
    end

    def tags
      ActiveModel::ArraySerializer.new(object.tags, serializer: TagSerializer)
    end

    def raw
      object.first_post&.raw
    end

    def cooked
      object.first_post&.cooked
    end

    def date
      from_event_tag :date
    end

    def event_type
      from_event_tag :type
    end

    def confirmed
      from_event_tag(:confirmed).present?
    end

    private

    def include_event?
      object.respond_to?(:has_event?) && object.has_event?
    end

    def from_event_tag(prefix, length: 11)
      object.tags
            .map(&:name)
            .detect { |name| name.starts_with?("event-#{prefix}") }
            .to_s
            .sub("event-#{prefix}-", '')
            .slice(0, length)
    end
  end
end
