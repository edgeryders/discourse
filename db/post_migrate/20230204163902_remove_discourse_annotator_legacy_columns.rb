class RemoveDiscourseAnnotatorLegacyColumns < ActiveRecord::Migration[6.1]
  def change
    remove_column :discourse_annotator_codes, :name_legacy, if_exists: true
    remove_column :discourse_annotator_user_settings, :propose_codes_from_users, if_exists: true
    remove_column :discourse_annotator_user_settings, :discourse_tag_id, if_exists: true
  end
end
