module AnnotatorStore
  class VideoAnnotation < Annotation

    # Validations
    validates :uri, presence: true
    validates :container, presence: true
    validates :src, presence: true
    validates :ext, presence: true
    validates :start, presence: true
    validates :end, presence: true



    def video_annotation?
      true
    end

  end
end
