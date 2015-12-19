class AddIndexJobToJobReward < ActiveRecord::Migration
  def change
    add_column :jobs, :job_reward_id, :integer
  end
end
