class AddAnnotationsCounterCache < ActiveRecord::Migration[5.2]

  def change
    #add_column :annotator_store_tags, :annotations_count, :bigint,  null: false, default: 0

    #add_index :annotator_store_localized_tags, [:tag_id, :language_id], unique: true

  end


end
