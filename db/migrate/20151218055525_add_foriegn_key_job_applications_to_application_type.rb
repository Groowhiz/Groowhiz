class AddForiegnKeyJobApplicationsToApplicationType < ActiveRecord::Migration
  def change
    add_column :job_applications, :application_type_id, :integer
  end
end
