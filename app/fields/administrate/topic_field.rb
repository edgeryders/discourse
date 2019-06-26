require "administrate/field/belongs_to"

module Administrate
  class TopicField < Administrate::Field::BelongsTo

    def to_s
      data
    end

  end
end
