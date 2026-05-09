class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.string :code, limit: 50, null: false
      t.integer :discount_type, null: false, default: 0 # enum: { percent: 0, fixed: 1 }
      t.decimal :discount_value, precision: 10, scale: 2, null: false
      t.decimal :min_order_value, precision: 10, scale: 2, null: false, default: 0
      t.integer :max_uses, null: true
      t.integer :uses_count, null: false, default: 0
      t.datetime :valid_from, null: false
      t.datetime :valid_until, null: false
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end
  end
end
