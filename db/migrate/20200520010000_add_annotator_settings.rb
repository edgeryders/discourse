class AddAnnotatorSettings < ActiveRecord::Migration[5.2]


  def change


    create_table :annotator_store_settings do |t|
      t.boolean :public_codes_list_api_endpoint, null: false, default: false
    end


  end


end
