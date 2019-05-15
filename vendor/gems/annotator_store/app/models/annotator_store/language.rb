module AnnotatorStore
  class Language < ActiveRecord::Base

    # Associations
    has_many :tag_names, dependent: :restrict_with_exception

    # Validations
    validates :name, presence: true, uniqueness: {case_sensitive: false}
    validates :locale, presence: true, uniqueness: {case_sensitive: false}


    def self.english
      AnnotatorStore::Language.find_by(locale: 'en')
    end


  end
end
