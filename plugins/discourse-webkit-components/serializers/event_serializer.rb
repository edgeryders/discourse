module WebkitComponents
  class EventSerializer < TopicSerializer
    attributes :location, :date, :event_type, :confirmed

    def location
      from_event_tag :location, length: 15
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

    def from_event_tag(prefix, length: 11)
      object.tags
            .detect { |tag| tag.name.starts_with?("event-#{prefix}") }
            .to_s
            .sub("event-#{prefix}-", '')
            .slice(0, length)
    end
  end
end
