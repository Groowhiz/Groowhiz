class Job < ActiveRecord::Base
  include RankedModel
  include ERB::Util


  belongs_to :project
  belongs_to :category
  belongs_to :job_reward



  delegate :display_description, :display_deliver_estimate, to: :decorator
end
