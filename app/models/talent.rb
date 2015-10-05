class Talent < ActiveRecord::Base
  PUBLISHED_STATES = ['published']
  HEADLINE_MAXLENGTH = 100

  include PgSearch

  include Shared::StateMachineHelpers
  include Shared::Queued

  include Talent::StateMachineHandler
  include Talent::CustomValidators
  include Talent::ErrorGroups

   # has_notifications

  # delegate  :display_online_date, :display_card_status, :display_status, :progress,
  #           :display_image, :display_expires_at, :remaining_text, :time_to_go,
  #           :display_pledged, :display_pledged_with_cents, :display_goal, :remaining_days, :progress_bar,
  #           :status_flag, :state_warning_template, :display_card_class, :display_errors, to: :decorator

  belongs_to :user
  belongs_to :category

  has_many :talent_videos, class_name: "TalentVideo", inverse_of: :talent, reject_if: ->(x) { x['talent_video'].blank? }
  # has_many :talent_images, class_name: "TalentImage", inverse_of: :talent, reject_if: ->(x) { x['image'].blank? }


  accepts_nested_attributes_for :talent_videos, allow_destroy: true
  # accepts_nested_attributes_for :talent_images, allow_destroy: true

  accepts_nested_attributes_for :user

  pg_search_scope :search_tsearch,
                  against: "full_text_index",
                  using: {
                      tsearch: {
                          dictionary: "portuguese",
                          tsvector_column: "full_text_index"
                      }
                  },
                  ignoring: :accents

  pg_search_scope :search_trm,
                  against: "name",
                  using: :trigram,
                  ignoring: :accents

  def self.pg_search term
    search_tsearch(term).presence || search_trm(term)
  end

  # Used to simplify a has_scope
  scope :published, ->{ with_state('published') }

  scope :by_user_email, ->(email) { joins(:user).where("users.email = ?", email) }
  scope :by_id, ->(id) { where(id: id) }

  scope :by_category_id, ->(id) { where(category_id: id) }
  scope :by_updated_at, ->(updated_at) { where(updated_at: Time.zone.parse( updated_at ).. Time.zone.parse( updated_at ).end_of_day) }
  scope :by_permalink, ->(p) { without_state('deleted').where("lower(permalink) = lower(?)", p) }
  scope :recommended, -> { where(recommended: true) }
  scope :name_contains, ->(term) { where("unaccent(upper(name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :user_name_contains, ->(term) { joins(:user).where("unaccent(upper(users.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }

  scope :near_of, ->(address_state) { where("EXISTS(SELECT true FROM users u WHERE u.id = talents.user_id AND lower(u.address_state) = lower(?))", address_state) }
  scope :visible, -> { without_states(['draft', 'rejected', 'deleted']) }

  scope :ordered, -> { order(created_at: :desc)}

  scope :most_recent_first, ->{ order("talents.created_at DESC") }

  attr_accessor :accepted_terms

  validates_acceptance_of :accepted_terms, on: :create

  ##validation for all states
  validates_presence_of :name, :user_id, :category_id, :permalink

  validates_uniqueness_of :permalink, case_sensitive: false
  validates_format_of :permalink, with: /\A(\w|-)*\Z/

  [:between_created_at, :between_updated_at].each do |name|
    define_singleton_method name do |starts_at, ends_at|
      return all unless starts_at.present? && ends_at.present?
      field = name.to_s.gsub('between_','')
      where(field => Time.zone.parse( starts_at ).. Time.zone.parse( ends_at ).end_of_day)
    end
  end

  def self.order_by(sort_field)
    return self.all unless sort_field =~ /^\w+(\.\w+)?\s(desc|asc)$/i
    order(sort_field)
  end


  def can_show_preview_link?
    !published?
  end

  def decorator
    @decorator ||= TalentDecorator.new(self)
  end

  def published?
    PUBLISHED_STATES.include? state
  end

  def expires_fragments *fragments
    base = ActionController::Base.new
    fragments.each do |fragment|
      base.expire_fragment([fragment, id])
    end
  end

  def to_analytics
    {
        id: self.id,
        permalink: self.permalink,
        talent_state: self.state,
        category: self.category.name_pt,
        talent_created_date: self.created_at
    }
  end

  def to_analytics_json
    to_analytics.to_json
  end

end
