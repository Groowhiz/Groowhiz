class CreateTalent < ActiveRecord::Migration
  def change
    create_table :talents, permalink: :uuid do |t|
      t.string :title
      t.text :description
      t.integer :category_id
      t.integer :user_id
      t.boolean :recommended, :default => false
      t.string :state

      t.timestamps
    end
  end
end
