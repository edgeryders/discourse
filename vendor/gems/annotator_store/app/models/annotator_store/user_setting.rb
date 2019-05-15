module AnnotatorStore
  class UserSetting < ActiveRecord::Base

    # Associations
    belongs_to :discourse_user, class_name: '::User'
    belongs_to :language

    # Validations
    validates :discourse_user, presence: true, uniqueness: true
    validates :language, presence: true



    def self.language_for_user(user)
      AnnotatorStore::UserSetting.find_by(discourse_user_id: user.id)&.language
    end


  end
end
