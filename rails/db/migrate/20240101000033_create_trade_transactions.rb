class CreateTradeTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :trade_transactions do |t|
      t.decimal :final_price, precision: 10, scale: 2, null: false
      t.decimal :platform_fee, precision: 10, scale: 2, null: false
      t.integer :status, null: false, default: 0 # enum: { pending: 0, completed: 1, disputed: 2, refunded: 3 }
      t.datetime :completed_at, null: true
      t.references :listing, null: false, foreign_key: { to_table: :trade_listings, on_delete: :restrict }
      t.references :buyer, null: false, foreign_key: { to_table: :players, on_delete: :restrict }
      t.references :seller, null: false, foreign_key: { to_table: :players, on_delete: :restrict }

      t.timestamps
    end
    add_index :trade_transactions, :listing_id, unique: true
  end
end
