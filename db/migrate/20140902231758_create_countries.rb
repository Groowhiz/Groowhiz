class CreateCountries < ActiveRecord::Migration
  def up
    create_table :countries do |t|
      t.text :name, null: false
      t.timestamps
    end
  end

  def down
    drop_table :countries
  end
end
