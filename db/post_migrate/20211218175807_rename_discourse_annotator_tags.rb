class RenameDiscourseAnnotatorTags < ActiveRecord::Migration[6.1]
  def change
    rename_table :discourse_annotator_tags, :discourse_annotator_codes
    rename_table :discourse_annotator_localized_tags, :discourse_annotator_localized_codes
    rename_table :discourse_annotator_tag_names, :discourse_annotator_code_names

    rename_column :discourse_annotator_annotations, :tag_id, :code_id
    rename_column :discourse_annotator_localized_codes, :tag_id, :code_id
    rename_column :discourse_annotator_code_names, :tag_id, :code_id

  end
end