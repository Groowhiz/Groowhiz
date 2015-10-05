class CreateTalentLinks < ActiveRecord::Migration
  def change
    create_table :talent_videos do |t|
      t.integer :talent_id
      t.integer :user_id
      t.text :video_url
      t.text :video_thumbnail
      t.string :video_embed_url

      t.timestamps
    end

    create_table :talent_images do |t|
      t.integer :talent_id
      t.integer :user_id
      t.text :image_url

      t.timestamps
    end

  end
end
