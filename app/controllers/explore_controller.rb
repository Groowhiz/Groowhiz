class ExploreController < ApplicationController
  layout 'catarse_bootstrap'
  def index
    p "I came to Explore Controller"
    @categories = Category.with_projects.order(:name_pt).all
    @categories = Category.with_talents.order(:name_pt).all
    @genres=Genre.with_projects.order(:name_pt).all
  end
end

