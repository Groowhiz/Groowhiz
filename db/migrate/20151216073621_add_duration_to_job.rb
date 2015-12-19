class AddDurationToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :job_start_date, :datetime
    add_column :jobs, :job_end_date, :datetime
  end
end
