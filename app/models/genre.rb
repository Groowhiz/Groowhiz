class Genre < ActiveRecord::Base
  has_notifications
  has_many :projects
  has_many :talents
  has_many :users

  delegate :genre_display_name, to: :decorator


  validates_presence_of :name_pt
  validates_uniqueness_of :name_pt

  def self.array
    order('name_'+ I18n.locale.to_s + ' ASC').collect { |c| [c.send('name_' + I18n.locale.to_s), c.id] }
  end

  def to_s
    self.send('name_' + I18n.locale.to_s)
  end

  def decorator
    @decorator ||= GenreDecorator.new(self)
  end
end
