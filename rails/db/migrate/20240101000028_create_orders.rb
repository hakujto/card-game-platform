class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.integer :status, null: false, default: 0 # enum: { pending: 0, paid: 1, processing: 2, shipped: 3, completed: 4, cancelled: 5, refunded: 6 }
      t.decimal :total, precision: 10, scale: 2, null: false, default: 0
      t.decimal :discount_applied, precision: 10, scale: 2, null: false, default: 0
      t.string :currency, limit: 3, null: false, default: 'USD'
      t.integer :payment_method, null: false, default: 0 # enum: { card: 0, pay_pal: 1, crypto: 2, platform_credits: 3 }
      t.string :payment_reference, limit: 200, null: true
      t.text :shipping_address, null: true
      t.string :tracking_number, limit: 100, null: true
      t.datetime :paid_at, null: true
      t.datetime :shipped_at, null: true
      t.references :player, null: false, foreign_key: { to_table: :players }
      t.references :coupon, null: true, foreign_key: { to_table: :coupons }

      t.timestamps
    end
  end
end
