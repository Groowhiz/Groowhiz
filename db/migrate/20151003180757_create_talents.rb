class CreateTalents < ActiveRecord::Migration
  def change
    create_table :talents do |t|
      t.string :name
      t.text :description
      t.string :video_url
      t.string :text
      t.integer :category_id
      t.integer :user_id
      t.string :uploaded_image
      t.string :text

      t.timestamps
    end
  end
end
