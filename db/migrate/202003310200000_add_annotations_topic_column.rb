class AddAnnotationsTopicColumn < ActiveRecord::Migration[5.2]

  def up
    add_column :annotator_store_annotations, :topic_id, :bigint

    AnnotatorStore::Annotation.find_each do |a|
      a.update_column(:topic_id, a.post&.topic_id)
    end

  end


end
