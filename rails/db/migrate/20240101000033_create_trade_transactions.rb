class CreateTradeTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :trade_transactions do |t|
      t.decimal :final_price, precision: 10, scale: 2, null: false
      t.decimal :platform_fee, precision: 10, scale: 2, null: false
      t.integer :status, null: false, default: 0 # enum: { pending: 0, completed: 1, disputed: 2, refunded: 3 }
      t.datetime :completed_at, null: true
      t.references :listing, null: false, foreign_key: { to_table: :tradelistings }
      t.references :buyer, null: false, foreign_key: { to_table: :players }
      t.references :seller, null: false, foreign_key: { to_table: :players }

      t.timestamps
    end
  end
end
