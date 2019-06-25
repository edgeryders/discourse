module AnnotatorStore
  class Range < ActiveRecord::Base
    # Associations
    belongs_to :annotation, class_name: 'TextAnnotation'

    # Validations
    validates :start_offset, presence: true
    validates :end_offset, presence: true
  end
end
