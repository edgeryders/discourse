module PostAnnotatable
  extend ActiveSupport::Concern
  included do


    has_many :annotations, dependent: :delete_all, class_name: 'AnnotatorStore::Annotation'


  end
end
