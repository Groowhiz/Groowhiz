class AddLocationForProjects < ActiveRecord::Migration
  def change
    create_table :costates do |t|
      t.string   "name",       null: false
      t.string   "acronym",    null: false
      t.timestamps
      t.index ["acronym"], :name => "costates_acronym_unique", :unique => true
      t.index ["name"], :name => "costates_name_unique", :unique => true
    end
    add_column :projects, :city_id, :integer
    add_column :projects, :country_id, :integer
    add_column :projects, :costate_id, :integer
    add_column :projects, :other_country, :string
    add_column :projects, :other_city, :string
  end
end
