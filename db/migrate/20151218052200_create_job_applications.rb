class CreateJobApplications < ActiveRecord::Migration
  def change
    create_table :job_applications, force: true do |t|
      t.integer "job_id"
      t.string "video_url"
      t.string "link__ref1"
      t.string "link__ref2"
      t.integer "creator"
      t.integer "artist"
      t.string "status"
      t.text "reason"
      t.timestamps
    end
  end
end
