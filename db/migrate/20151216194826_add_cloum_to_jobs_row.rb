class AddCloumToJobsRow < ActiveRecord::Migration
  def change
    add_column :jobs, :row_order, :integer
  end
end
