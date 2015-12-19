class AddIndexTalentToGenre < ActiveRecord::Migration
  def change
    add_column :talents, :genre_id, :integer
  end
end
