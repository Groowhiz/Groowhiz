class CreateCountries < ActiveRecord::Migration
  def up
    create_table :countries do |t|
      t.text :name, null: false
      t.timestamps
    end
    execute <<-SQL
      INSERT INTO countries (name) VALUES
      ('India'), ('Others');
      UPDATE countries SET created_at = now(), updated_at = now();
    SQL
  end

  def down
    drop_table :countries
  end
end
