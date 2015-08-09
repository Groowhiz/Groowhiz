class CreatePaymentLogs < ActiveRecord::Migration
  def change
=begin
    create_table :payment_logs do |t|
      t.string :gateway_id, null: false, foreign_key: false
      t.column :data, :json, null: false

      t.timestamps
    end
=end
  end
end
