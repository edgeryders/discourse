require "administrate/field/string"

class Annotator::TopicField < Administrate::Field::String

  def to_s
    data
  end

end
