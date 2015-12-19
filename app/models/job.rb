class Job < ActiveRecord::Base
  include RankedModel
  include ERB::Util

  validates_presence_of :job_description, :job_start_date, :job_end_date


  ranks :row_order, with_same: :project_id

  belongs_to :project
  #belongs_to :category
  #belongs_to :job_reward
  has_many :job_applications

  scope :sort_asc, -> { order('id ASC') }

  delegate :display_description, :display_deliver_estimate, to: :decorator

  before_save :log_changes
  after_save :expires_project_cache

  def log_changes
    self.last_changes = self.changes.to_json
  end

  def expires_project_cache
    project.expires_fragments 'project-jobs'
  end


  def decorator
    @decorator ||= JobDecorator.new(self)
  end

end
