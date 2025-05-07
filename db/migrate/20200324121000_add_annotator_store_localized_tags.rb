class AddAnnotatorStoreLocalizedTags < ActiveRecord::Migration[5.2]
  def change


    create_table :annotator_store_localized_tags do |t|
      t.string :name, null: false
      t.string :path, null: false
      t.belongs_to :tag, index: true, null: false
      t.belongs_to :language, index: true, null: false
      t.timestamps
    end

    add_index :annotator_store_localized_tags, [:path, :language_id], unique: true


  end
end
