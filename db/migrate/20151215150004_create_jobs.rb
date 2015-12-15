class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs, force true do |t|
      t.string "job_name"
      t.integer "project_id"
      t.integer "category_id"
      t.string "job_description"
      t.string "gender"
      t.integer "job_count"
      t.integer "duration"
      t.string "status"
      t.timestamps
    end
  end
end
