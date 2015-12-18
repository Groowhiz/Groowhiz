class CreateJobPerks < ActiveRecord::Migration
  def change
    create_table :job_perks do |t|

      t.timestamps
    end
  end
end
