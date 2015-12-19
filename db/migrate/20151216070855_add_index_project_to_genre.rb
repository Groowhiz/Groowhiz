class AddIndexProjectToGenre < ActiveRecord::Migration
  def change
    add_column :projects, :genre_id, :integer
  end
end
