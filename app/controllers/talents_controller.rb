
class TalentsController < ApplicationController
  has_scope :pg_search, :by_category_id, :near_of
  has_scope :recent, :recommended, type: :boolean

  respond_to :html
  # respond_to :json, only: [:index, :show, :update]

  def index
  end

  def edit
  end

  def show
  end

  def new
    p "HEY YOYOYOYO"
    p "Talents Controller => Current User is: #{current_user}"
    @talent = Talent.new user: current_user
    p "Talents Controller =>   Talent is: #{@talent}"
    # authorize @project
    @talent.talent_images.build
    p "Talents Controller => Talent image is: #{@talent}"

    @talent.talent_videos.build
    p "Talents Controller => Talent video is: #{@talent}"

    @talent
  end
end
