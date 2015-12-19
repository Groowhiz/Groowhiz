class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities, force:true do |t|
      t.string   "name",       null: false
      t.string   "acronym",    null: false
      t.datetime "created_at", :default => { :expr => "now()" }
      t.datetime "updated_at"
      t.index ["acronym"], :name => "cities_acronym_unique", :unique => true
      t.index ["name"], :name => "cities_name_unique", :unique => true
    end
  end
end
