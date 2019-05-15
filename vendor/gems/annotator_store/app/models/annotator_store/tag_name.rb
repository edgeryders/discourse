module AnnotatorStore
  class TagName < ActiveRecord::Base

    # Associations
    belongs_to :tag
    belongs_to :language

    # Validations
    validates :name, presence: true
    validates :language, presence: true, uniqueness: {scope: [:tag_id]}
    validates :tag, presence: true


  end
end
