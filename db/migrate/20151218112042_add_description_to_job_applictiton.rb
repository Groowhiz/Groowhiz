class AddDescriptionToJobApplictiton < ActiveRecord::Migration
  def change
    add_column :job_applications, :description, :text
  end
end
