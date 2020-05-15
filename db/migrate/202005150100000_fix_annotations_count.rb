class FixAnnotationsCount < ActiveRecord::Migration[5.2]


  def change
    AnnotatorStore::Tag.fix_annotations_count
  end


end
