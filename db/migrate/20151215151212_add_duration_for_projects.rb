class AddDurationForProjects < ActiveRecord::Migration
  def change
    add_column :projects, :project_start_date, :datetime
    add_column :projects, :project_end_date, :datetime
  end
end
