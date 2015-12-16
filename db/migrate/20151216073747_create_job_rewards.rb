class CreateJobRewards < ActiveRecord::Migration
  def change
    create_table :job_rewards, force: true do |t|
      t.string "job_reward_name"
      t.timestamps
    end
  end
end
