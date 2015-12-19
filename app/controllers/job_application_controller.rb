class JobApplicationController < ApplicationController
  def index
  end


  def new
    @job_application = JobApplication.new user: current_user
    authorize @job_application
  end
end
