
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
    p "Talents Controller => Current User is: #{current_user.inspect}"
    @talent = Talent.new user: current_user
    p "Talents Controller =>   Talent is: #{@talent.inspect}"
    # authorize @talent

    # @talent.talent_images.build
    # p "Talents Controller => Talent image is: #{@talent}"

    @talent.talent_videos.build
    p "Talents Controller => Talent video is: #{@talent.inspect}"

    @talent
  end

  def create
    @talent = Talent.new
    p "Talents Controller create =>   Talent is: #{@talent.inspect}"

    @talent.attributes = permitted_params.merge(user: current_user)
    p "Talents Controller create attributes =>   Talent is: #{@talent.inspect}"

    # authorize @talent
    if @talent.save
      p "Talents Controller create  save =>   Talent is: #{@talent.inspect}"
      redirect_to edit_user_path(@talent, anchor: 'talents')
    else
      p "Talents Controller create else =>   Talent is: #{@talent.inspect}"
      render :new
    end
  end

  def permitted_params
    p "Yes came to permitted params"
    params.require(:talent).permit(policy(resource).permitted_attributes)
  end

  def resource
    p "yes came to resource"
    @talent ||=  Talent.find(params[:id])
  end

end
