class Projecttagline < ActiveRecord::Migration
  def change
    add_column :projects, :tagline, :text
  end
end
