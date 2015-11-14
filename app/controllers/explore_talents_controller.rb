class ExploreTalentsController < ApplicationController
  layout 'catarse_bootstrap'
  def index
    @categories = Category.with_talents.order(:name_pt).all
  end
end
