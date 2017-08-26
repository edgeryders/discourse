module AnnotatorStore
  class Tag < ActiveRecord::Base

    # https://github.com/stefankroes/ancestry
    has_ancestry

    # Associations
    belongs_to :creator, class_name: 'User'
    has_many :annotations, dependent: :destroy

    # Validations
    validates :name, presence: true, uniqueness: {scope: :ancestry, case_sensitive: false}
    validates :creator, presence: true

  end
end
