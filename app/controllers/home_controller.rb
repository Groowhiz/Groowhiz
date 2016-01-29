class HomeController < ApplicationController

  def index
    p "Home Index begin"
    # @recommends = ProjectsForHome.recommends.includes(:project_total, :user)
    # @projects_near = Project.with_state('online').near_of(current_user.address_state).order("random()").limit(3).includes(:project_total, :user) if current_user
    # @expiring = ProjectsForHome.expiring.includes(:project_total, :user)
    # @recent   = ProjectsForHome.recents.includes(:project_total, :user)
    p "#{@recommends.inspect}"
    @talents_recommends = TalentsForHome.recommends.includes(:user)

    #@talents_near = Talent.with_state('online','published').near_of(current_user.address_state).order("random()").limit(3).includes(:user) if current_user
    @talents_recent   = TalentsForHome.recents.includes(:user)
    p "#{@talents_recent.inspect}"

    p "#{@talents_recommends.inspect}"
    p "Home Render"
    render('index')
  end

end
