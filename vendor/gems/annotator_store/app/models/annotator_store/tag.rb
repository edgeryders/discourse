module AnnotatorStore
  class Tag < ActiveRecord::Base

    attr_accessor :merge_tag_id

    # https://github.com/stefankroes/ancestry
    has_ancestry

    # Associations
    belongs_to :creator, class_name: '::User'
    has_many :annotations, dependent: :destroy
    has_many :names, dependent: :destroy, class_name: 'TagName'

    accepts_nested_attributes_for :names


    # Validations
    #validates :name, presence: true, uniqueness: {scope: [:ancestry, :creator_id], case_sensitive: false}
    validates :creator, presence: true
    validates :names, length: {minimum: 1, too_short: ": One name is required"}

    # Callbacks
    after_save do
      if merge_tag_id.present?
        t = AnnotatorStore::Tag.find(merge_tag_id)
        t.annotations.update_all(tag_id: id)
        t.destroy
      end
    end


    # Alias. Used by administrate
    def name
      translated_name
    end


    # --- Class Finder Methods --- #

    def self.with_annotations_count
      select('annotator_store_tags.*, count(annotator_store_annotations.id) AS annotations_count').
        joins('LEFT OUTER JOIN annotator_store_annotations on annotator_store_annotations.tag_id = annotator_store_tags.id').
        group('annotator_store_tags.id')
    end


    # --- Instance Methods --- #

    def translated_name(language=nil)
      (language.present? ? names.find_by(language_id: language.id)&.name : nil) ||
        names.find_by(language_id: AnnotatorStore::Language.english.id)&.name ||
        names.order(created_at: :asc).first&.name
    end


  end
end
