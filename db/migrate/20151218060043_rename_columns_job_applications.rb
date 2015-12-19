class RenameColumnsJobApplications < ActiveRecord::Migration
  def change
    rename_column :job_applications, :link__ref1, :link_ref1
    rename_column :job_applications, :link__ref2, :link_ref2
  end
end
