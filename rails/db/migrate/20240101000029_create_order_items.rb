class CreateOrderItems < ActiveRecord::Migration[7.1]
  def change
    create_table :order_items do |t|
      t.integer :quantity, null: false
      t.decimal :price_at_purchase, precision: 10, scale: 2, null: false
      t.boolean :foil, null: false, default: false
      t.references :order, null: true, foreign_key: { to_table: :orders }
      t.references :product, null: false, foreign_key: { to_table: :products }

      t.timestamps
    end
  end
end
