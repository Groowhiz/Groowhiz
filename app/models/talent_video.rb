class TalentVideo < ActiveRecord::Base
  include Talent::VideoHandler

  belongs_to :user
  belongs_to :talent

end
