class CreateTalentLinks < ActiveRecord::Migration
  def change
    create_table :talent_links do |t|
      t.integer :talent_id
      t.string :video_url
      t.string :uploaded_image

      t.timestamps
    end
  end
end
