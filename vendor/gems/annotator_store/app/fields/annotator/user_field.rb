require "administrate/field/belongs_to"

class Annotator::UserField < Administrate::Field::BelongsTo

  def to_s
    data
  end

end
