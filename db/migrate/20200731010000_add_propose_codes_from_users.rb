class AddProposeCodesFromUsers < ActiveRecord::Migration[5.2]


  def change
    add_column :annotator_store_user_settings, :propose_codes_from_users, :string
  end


end
