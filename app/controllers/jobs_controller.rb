class JobsController < ApplicationController
  respond_to :html, :json
  helper_method :resource, :parent

  def new

  end

  def create

  end

  def delete

  end

  def destroy

  end

  def resource
    @job ||= parent.jobs.find params[:id]
  end

  def parent
    @project ||= Project.find params[:project_id]
  end



end
