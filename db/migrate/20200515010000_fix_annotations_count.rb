class FixAnnotationsCount < ActiveRecord::Migration[5.2]


  def change
    DiscourseAnnotator::Code.fix_annotations_count
  end


end
