class InitializeDiscourseAnnotator < ActiveRecord::Migration[6.1]

  # This migration replaces all migrations up to 2021-12-17 which became necessary as (1) the `AnnotatorStore` namespace used
  # in previous migrations is now `DiscourseAnnotator` and (2) to resolve issues with previous migrations ( https://github.com/edgeryders/discourse/issues/243 ).
  #
  # The migration initializes the discourse-annotator gem in case no previous migrations were run.
  # It also works to make the transition from `annotator-store-gem` to `discourse-annotator` which requires all
  # of the gems tables to be renamed.
  # For this to work it is required that all migrations up to (including) 2021-09-12 were executed. These are all
  # migrations as seen here: https://github.com/edgeryders/discourse-annotator/tree/70eb0c4d0cfd724caa0508efc8d3f3af59be98d9/db/migrate
  #
  # Note: To run the migration in Discourse copy it into db/post_migrate/
  def change

    if ActiveRecord::Base.connection.table_exists?('annotator_store_annotations')
      rename_table 'annotator_store_annotations', 'discourse_annotator_annotations'
    end

    if ActiveRecord::Base.connection.table_exists?('annotator_store_languages')
      rename_table 'annotator_store_languages', 'discourse_annotator_languages'
    end

    if ActiveRecord::Base.connection.table_exists?('annotator_store_localized_tags')
      remove_index :annotator_store_localized_tags, [:tag_id, :language_id], if_exists: true
      rename_table 'annotator_store_localized_tags', 'discourse_annotator_localized_tags'
    end

    if ActiveRecord::Base.connection.table_exists?('annotator_store_ranges')
      rename_table 'annotator_store_ranges', 'discourse_annotator_ranges'
    end

    if ActiveRecord::Base.connection.table_exists?('annotator_store_settings')
      rename_table 'annotator_store_settings', 'discourse_annotator_settings'
    end

    if ActiveRecord::Base.connection.table_exists?('annotator_store_tag_names')
      remove_index :annotator_store_tag_names, [:tag_id, :language_id], if_exists: true
      rename_table 'annotator_store_tag_names', 'discourse_annotator_tag_names'
    end

    if ActiveRecord::Base.connection.table_exists?('annotator_store_tags')
      remove_index :annotator_store_tags, :ancestry, if_exists: true
      rename_table 'annotator_store_tags', 'discourse_annotator_tags'
    end

    if ActiveRecord::Base.connection.table_exists?('annotator_store_user_settings')
      rename_table 'annotator_store_user_settings', 'discourse_annotator_user_settings'
    end

    create_table :discourse_annotator_annotations, if_not_exists: true do |t|
      t.string :version # Schema version
      t.text :text # Content of annotation
      t.text :quote # The annotated text
      t.string :uri # URI of annotated document
      t.timestamps # Time created_at and updated_at for annotation
      t.integer :tag_id
      t.integer :post_id
      t.integer :creator_id
      t.bigint :topic_id
      t.string :type
      t.string :shape
      t.string :units
      t.string :geometry
      t.string :src
      t.string :ext
      t.string :container
      t.string :start
      t.string :end
    end

    create_table :discourse_annotator_ranges, if_not_exists: true do |t|
      t.references :annotation, index: true # Associated annotation's id
      t.string :start # Relative XPath to start element
      t.string :end # Relative XPath to end element
      t.integer :start_offset # Character offset within start element
      t.integer :end_offset # Character offset within end element
      t.timestamps # Time created_at and updated_at for range
    end

    create_table :discourse_annotator_tags, if_not_exists: true do |t|
      t.string :name
      t.text :description
      t.belongs_to :creator, index: true
      t.timestamps
      t.string :ancestry
      t.bigint :annotations_count, null: false, default: 0
    end

    create_table :discourse_annotator_tag_names, if_not_exists: true do |t|
      t.string :name, null: false
      t.belongs_to :tag, index: true
      t.belongs_to :language, index: true, null: false
      t.timestamps
    end

    create_table :discourse_annotator_languages, if_not_exists: true do |t|
      t.string :name, null: false
      t.string :locale, null: false
      t.timestamps
    end

    create_table :discourse_annotator_user_settings, if_not_exists: true do |t|
      t.belongs_to :discourse_user, index: true, null: false
      t.belongs_to :language, index: true, null: false
      t.bigint :discourse_tag_id
      t.string :propose_codes_from_users
    end

    create_table :discourse_annotator_localized_tags, if_not_exists: true do |t|
      t.string :name, null: false
      t.string :path, null: false
      t.belongs_to :tag, index: true, null: false
      t.belongs_to :language, index: true, null: false
      t.timestamps
    end

    create_table :discourse_annotator_settings, if_not_exists: true do |t|
      t.boolean :public_codes_list_api_endpoint, null: false, default: false
    end

    add_index :discourse_annotator_tags, :ancestry, if_not_exists: true
    add_index :discourse_annotator_localized_tags, [:tag_id, :language_id], name: 'discourse_annotator_localized_tags_unique', unique: true, if_not_exists: true
    add_index :discourse_annotator_tag_names, [:tag_id, :language_id], name: 'discourse_annotator_tag_names_unique', unique: true, if_not_exists: true

    DiscourseAnnotator::Annotation.where(type: 'AnnotatorStore::TextAnnotation').update_all(type: 'DiscourseAnnotator::TextAnnotation')
    DiscourseAnnotator::Annotation.where(type: 'AnnotatorStore::ImageAnnotation').update_all(type: 'DiscourseAnnotator::ImageAnnotation')
    DiscourseAnnotator::Annotation.where(type: 'AnnotatorStore::VideoAnnotation').update_all(type: 'DiscourseAnnotator::VideoAnnotation')

  end
end
