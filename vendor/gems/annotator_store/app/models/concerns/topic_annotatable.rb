module TopicAnnotatable
  extend ActiveSupport::Concern
  included do


    def self.all_with_annotations
      Topic.includes(posts: :annotations).where.not(annotator_store_annotations: {id: nil})
    end


  end
end
