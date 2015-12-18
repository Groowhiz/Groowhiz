class AddLastChangesToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :last_changes, :text
  end
end
