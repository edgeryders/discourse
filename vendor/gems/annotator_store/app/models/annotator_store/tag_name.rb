module AnnotatorStore
  class TagName < ActiveRecord::Base

    delegate :locale, to: :language


    # Associations
    belongs_to :tag
    belongs_to :language

    # Validations
    validates :name, presence: true
    validates :language, presence: true, uniqueness: {scope: [:tag_id]}
    validates :tag, presence: true


  end
end
