module AnnotatorStore
  class Annotation < ActiveRecord::Base

    # Associations
    belongs_to :tag
    belongs_to :creator, class_name: '::User'
    belongs_to :post

    # Validations
    validates :type, presence: true, inclusion: {in: %w(AnnotatorStore::TextAnnotation AnnotatorStore::ImageAnnotation AnnotatorStore::VideoAnnotation) }
    validates :creator, presence: true
    validates :tag, presence: true


    def topic
      post.topic
    end

    def text_annotation?
      false
    end

    def video_annotation?
      false
    end

    def image_annotation?
      false
    end

  end
end


