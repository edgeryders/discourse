class AddAnnotatorUserSettings < ActiveRecord::Migration[5.2]
  def change


    create_table :annotator_store_user_settings do |t|
      t.belongs_to :discourse_user, index: true, null: false
      t.belongs_to :language, index: true, null: false
    end


  end
end
