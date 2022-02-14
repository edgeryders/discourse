class AddAnnotationsCounterCache < ActiveRecord::Migration[5.2]

  def change
    add_column :annotator_store_tags, :annotations_count, :bigint,  null: false, default: 0

    add_index :annotator_store_localized_tags, [:tag_id, :language_id], unique: true


    DiscourseAnnotator::LocalizedCode.create_or_update_all

    DiscourseAnnotator::Code.find_each {|t| t.update_attribute(:annotations_count, t.annotations.count ) }

  end


end
