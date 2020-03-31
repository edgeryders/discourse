class RemoveCollectionTables < ActiveRecord::Migration[5.2]

  def up
    drop_table :annotator_store_collections_tags
    drop_table :annotator_store_collections
  end


end
