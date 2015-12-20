
class TalentsController < ApplicationController
  has_scope :pg_search, :by_category_id, :near_of, :by_genre_id
  has_scope :recent, :successful, :in_funding, :singing,  :song_writing, :instrumental, :music_compostion, :music_teaching, :music_production, :music_technology,
            :music_management, :band,:recommended, type: :boolean
  # after_filter :verify_authorized, except: %i[index video video_embed embed embed_panel about_mobile]
  after_filter :verify_authorized, except: %i[index video video_embed embed embed_panel about_mobile]
  after_filter :redirect_user_back_after_login, only: %i[index show]
  after_filter :redirect_user_back_after_login, only: %i[index show]

  respond_to :html
  respond_to :json, only: [:index, :show, :update]

  def index
    respond_to do |format|
      format.html do
        return render_index_for_xhr_request if request.xhr?
        talents_for_home
      end
      format.atom do
        return render layout: false, locals: {talents: talents}
      end
      format.rss { redirect_to talents_path(format: :atom), :status => :moved_permanently }
    end
  end



  def video
    talent = Talent.new(video_url: params[:url])
    render json: talent.video.to_json
  rescue VideoInfo::UrlError
    render json: nil
  end

  def embed
    resource
    render partial: 'card', layout: 'embed', locals: {embed_link: true, ref: (params[:ref] || 'embed')}
  end

  def embed_panel
    resource
    render partial: 'talent_embed'
  end

  def about_mobile
    resource
  end


  def by_category_id
    authorize resource

  end

  def render_index_for_xhr_request
    render partial: 'talents/card',
           collection: talents,
           layout: false,
           locals: {ref: "explore_talents", wrapper_class: 'w-col w-col-4 u-marginbottom-20'}
  end

  def talents_for_home
    p "Came to talents home"
    @talents_recommends = TalentsForHome.recommends.includes(:user)
    @talents_near = Talent.with_state('online','published').near_of(current_user.address_state).order("random()").limit(3).includes(:user) if current_user
    @talents_recent   = TalentsForHome.recents.includes(:user)
    return @talents_recommends,@talents_near,@talents_recent
  end


  def edit
  end

  def show
    p "Yes I came to show controller"
    fb_admins_add(resource.user.facebook_id) if resource.user.facebook_id
  end

  def new
    p "HEY YOYOYOYO"
    p "Talents Controller => Current User is: #{current_user.inspect}"
    @talent = Talent.new user: current_user
    p "Talents Controller =>   Talent is: #{@talent.inspect}"
    authorize @talent

    #@talent.talent_images.build
    # p "Talents Controller => Talent image is: #{@talent}"

    @talent.talent_videos.build
    p "Talents Controller => Talent video is: #{@talent.inspect}"

    @talent
  end

  def create
    @talent = Talent.new
    p "Talents Controller create =>   Talent is: #{@talent.inspect}"

    @some_variable = permitted_params
    p "Print the Some variable before thumbnail #{@some_variable.inspect}"

    update_video_thumbnail
    p "Print the Some variable after thumbnail #{@some_variable.inspect}"
    @new_variable = @some_variable['talent'].merge(user: current_user)
    p "Print the Some NEW variable #{@new_variable  .inspect}"

    @talent.attributes = @new_variable
    p "Talents Controller create attributes =>   Talent is: #{@talent.inspect}"
    p "Talents Controller create attributes =>   Talent is: #{@talent.talent_videos.inspect}"

    # @talent.talent_videos.each do |talent_video|
    #   p "Parsing each video #{talent_video.inspect}"
    #   talent_video.update_thumbnail
    #   p "Parsed each video #{talent_video.inspect}"
    # end
    authorize @talent
    if @talent.save
      p "Talents Controller create  save =>   Talent is: #{@talent.inspect}"
      redirect_to edit_user_path(current_user, anchor: 'talents')
    else
      p "Talents Controller create else =>   Talent is: #{@talent.inspect}"
      render :new
    end
  end

  def permitted_params
    p "Yes came to permitted params"
    params.require(:talent).permit(policy(resource).permitted_attributes)
  end

  def update_video_thumbnail
    p "Some varaible sdskmnfm #{@some_variable["talent"]["talent_videos_attributes"]}"
    @some_variable["talent"]["talent_videos_attributes"].each do |key, value|
      p "#{key} #{value}"
      p "#{@some_variable["talent"]["talent_videos_attributes"][key]}"
      video_url = @some_variable["talent"]["talent_videos_attributes"][key]["video_url"]
      video_piece = video_url.split("=")[1]
      @some_variable["talent"]["talent_videos_attributes"][key]["video_thumbnail"] = "https://img.youtube.com/vi/#{video_piece}/hqdefault.jpg"
      @some_variable["talent"]["permalink"] = SecureRandom.uuid
    end
  end


  def modal_url
    @talents=Talent.all
    @talents
  end

  def talents
    p "Did i come to talents() in controller?"
    page = params[:page] || 1
    p "Will apply scoping"
    @talents ||= apply_scopes(Talent.visible).
        most_recent_first.
        includes(:talent_videos, :user, :category).
        page(page).per(18)
    p "Now the talents returning are #{@talents.inspect}"
    @talents
  end

  def resource
    p "yes came to resource"
    @talent ||= (params[:permalink].present? ? Talent.by_permalink(params[:permalink]).first! : Talent.find(params[:id]))
  end

  # def talent_comments_canonical_url
  #   url = project_by_slug_url(resource.id, protocol: 'http', subdomain: 'www').split('/')
  #   url.delete_at(3) #remove language from url
  #   url.join('/')
  # end

end
