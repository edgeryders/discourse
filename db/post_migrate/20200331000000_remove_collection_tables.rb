class RemoveCollectionTables < ActiveRecord::Migration[5.2]

  def up
    drop_table :annotator_store_collections_tags, if_exists: true
    drop_table :annotator_store_collections, if_exists: true
  end


end
