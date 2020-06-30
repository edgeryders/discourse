class FixAnnotationsCount3 < ActiveRecord::Migration[5.2]


  def change
    AnnotatorStore::Tag.fix_annotations_count
  end


end
