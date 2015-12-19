class CreateApplicationTypes < ActiveRecord::Migration
  def change
    create_table :application_types, force: true do |t|
      t.string "type"
      t.timestamps
    end
  end
end
