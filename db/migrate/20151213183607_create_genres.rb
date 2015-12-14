class CreateGenres < ActiveRecord::Migration
  def change
    create_table "genres", force: true do |t|
      t.text     "name_pt",    null: false
      t.datetime "created_at", :default => { :expr => "now()" }
      t.datetime "updated_at"
      t.string   "name_en"
      t.string   "name_fr"
      t.index ["name_pt"], :name => "genres_name_unique", :unique => true
      t.index ["name_pt"], :name => "index_genres_on_name_pt"
    end
  end
end