class AddScreeningRoundsToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :screening_rounds, :integer
  end
end
