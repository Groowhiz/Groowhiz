class HomeController < ApplicationController

  def index
    @t_recommends,@t_near,@t_expiring,@t_recent= :talents_for_home
    @p_recommends,@p_near,@p_expiring,@p_recent= :projects_for_home
    render('index')
  end

end
