class AddLocationForProjects < ActiveRecord::Migration
  def change
    add_column :projects, :city_id, :integer
    add_column :projects, :country_id, :integer
    add_column :projects, :state_id, :integer
  end
end
