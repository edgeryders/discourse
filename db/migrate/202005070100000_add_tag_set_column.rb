class AddTagSetColumn < ActiveRecord::Migration[5.2]

  def up
    add_column :annotator_store_user_settings, :discourse_tag_id, :bigint


  end


end
