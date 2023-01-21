class RequireProjectForCode < ActiveRecord::Migration[6.1]
  def change
    change_column :discourse_annotator_codes, :project_id, :integer, null: false
  end
end
