class AutoCompleteTalentsController < ApplicationController

  has_scope :pg_search
  respond_to :html

  def index
    @talents = apply_scopes(Talent.with_state('recommended')).most_recent_first.limit(params[:limit])
    return render partial: 'talent', collection: @talents, layout: false
  end

end


