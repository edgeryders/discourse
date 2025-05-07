class AddProjects < ActiveRecord::Migration[6.1]
  def change

    create_table :discourse_annotator_projects, if_not_exists: true do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_column :discourse_annotator_codes, :project_id, :integer


  end
end
