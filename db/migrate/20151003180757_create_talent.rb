class CreateTalent < ActiveRecord::Migration
  def change
    create_table :talents do |t|
      t.string :title
      t.text :description
      t.integer :category_id
      t.integer :user_id
      t.boolean :recommended, :default => false
      t.string :state
      t.string :permalink

      t.timestamps
    end
  end
end
