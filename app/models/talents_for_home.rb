class TalentsForHome < Talent
  self.table_name = 'talents_for_home'

  scope :recommends, -> { where(origin: 'recommended') }
  scope :recents, -> { where(origin: 'recents') }

  def to_partial_path
    "talents/talent"
  end
end
