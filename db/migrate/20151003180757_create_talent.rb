class CreateTalent < ActiveRecord::Migration
  def change
    create_table :talents do |t|
      t.string :name
      t.text :description
      t.integer :category_id
      t.integer :user_id

      t.timestamps
    end
  end
end
