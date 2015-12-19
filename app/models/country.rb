class Country < ActiveRecord::Base
  has_many :projects

  validates_presence_of :name
  validates_uniqueness_of :name

  def self.array
    @array ||= order(:name).pluck(:name, :acronym).push(['other', 'other'])
  end
end
