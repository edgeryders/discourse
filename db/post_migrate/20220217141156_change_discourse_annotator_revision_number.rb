class ChangeDiscourseAnnotatorRevisionNumber < ActiveRecord::Migration[6.1]
  def change
    change_column :discourse_annotator_annotations, :revision_number, :integer, null: true

    DiscourseAnnotator::Annotation.update_all(revision_number: nil)
  end
end