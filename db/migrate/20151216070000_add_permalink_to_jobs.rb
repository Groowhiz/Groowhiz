class AddPermalinkToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :permalink, :text
    add_index :jobs, :permalink, unique: true
  end
end
