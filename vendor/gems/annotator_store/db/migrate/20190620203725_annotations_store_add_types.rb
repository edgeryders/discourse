class AnnotationsStoreAddTypes < ActiveRecord::Migration[5.2]
  def change


    change_table :annotator_store_annotations do |t|
      t.column :type, :string
      t.column :shape, :string
      t.column :units, :string
      t.column :geometry, :string
      t.column :src, :string
      t.column :ext, :string
      t.column :container, :string
      t.column :start, :string
      t.column :end, :string
    end
    AnnotatorStore::Annotation.update_all(type: 'AnnotatorStore::TextAnnotation')

  end
end
