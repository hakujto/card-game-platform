class CreateTradelistings < ActiveRecord::Migration[7.1]
  def change
    create_table :tradelistings do |t|
      t.integer :listing_type, null: false, default: 0 # enum: { fixed_price: 0, auction: 1, trade_offer: 2 }
      t.decimal :asking_price, precision: 10, scale: 2, null: true
      t.decimal :auction_start_price, precision: 10, scale: 2, null: true
      t.decimal :auction_current_bid, precision: 10, scale: 2, null: true
      t.datetime :auction_end_time, null: true
      t.boolean :foil, null: false, default: false
      t.integer :condition, null: false, default: 0 # enum: { mint: 0, near_mint: 1, excellent: 2, good: 3, played: 4 }
      t.integer :quantity, null: false, default: 1
      t.integer :status, null: false, default: 0 # enum: { active: 0, sold: 1, expired: 2, cancelled: 3, pending: 4 }
      t.text :description, null: true
      t.datetime :expires_at, null: true
      t.references :seller, null: false, foreign_key: { to_table: :players }
      t.references :card, null: false, foreign_key: { to_table: :cards }
      t.references :bids, null: true, foreign_key: { to_table: :trade_bids }

      t.timestamps
    end
  end
end
