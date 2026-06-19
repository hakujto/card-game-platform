class CreateTradeBids < ActiveRecord::Migration[7.1]
  def change
    create_table :trade_bids do |t|
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.datetime :placed_at, null: false
      t.boolean :is_winning, null: false, default: false
      t.references :listing, null: false, foreign_key: { to_table: :trade_listings, on_delete: :cascade }
      t.references :bidder, null: false, foreign_key: { to_table: :players, on_delete: :restrict }

      t.timestamps
    end
  end
end
