class Job < ActiveRecord::Base
  belongs_to :project
  belongs_to :category
  belongs_to :job_reward
end
