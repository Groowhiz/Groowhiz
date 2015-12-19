class JobApplication < ActiveRecord::Base
  belongs_to :job
  belongs_to :application_type

  validates_presence_of :description
  validates_length_of :description, :minimum=>10, :maximum=>100

end
