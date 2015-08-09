class CreatePaymentTransfers < ActiveRecord::Migration
  def change
=begin
    create_table :payment_transfers do |t|
      t.integer :user_id, null: false
      t.integer :payment_id, null: false
      t.text :transfer_id, null: false, foreign_key: false
      t.column :transfer_data, :json

      t.timestamps
    end
=end
  end
end
