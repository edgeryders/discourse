require "administrate/field/string"

class Annotator::AnnotationTypeField < Administrate::Field::String

  def to_s
    data.gsub(/AnnotatorStore::/,'')
  end

end
