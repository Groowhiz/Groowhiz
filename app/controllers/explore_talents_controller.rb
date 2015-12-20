class ExploreTalentsController < ApplicationController
  layout 'catarse_bootstrap'
  def index
    p "I came to Explore Controller"
    @categories = Category.with_talents.order(:name_pt).all
  end

  def by_category_id
    p "I am Coming to new Controller"
    @categories = Category.with_talents.order(:name_pt).all
  end

end

