class AddTagNamesUniqueIndex < ActiveRecord::Migration[5.2]


  def change
    add_index :annotator_store_tag_names, [:tag_id, :language_id], unique: true
  end


end