class AddAnnotatorStoreTagNames < ActiveRecord::Migration[5.2]
  def change


    create_table :annotator_store_tag_names do |t|
      t.string :name, null: false
      t.belongs_to :tag, index: true
      t.belongs_to :language, index: true, null: false
      t.timestamps
    end


  end
end
