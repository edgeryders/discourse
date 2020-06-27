class RemoveLocalizedTagsIndex < ActiveRecord::Migration[5.2]
  def change



    remove_index :annotator_store_localized_tags, [:path, :language_id]


  end
end
