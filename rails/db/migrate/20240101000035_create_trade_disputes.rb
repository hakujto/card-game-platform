class CreateTradeDisputes < ActiveRecord::Migration[7.1]
  def change
    create_table :trade_disputes do |t|
      t.integer :reason, null: false, default: 0 # enum: { item_not_received: 0, item_not_as_described: 1, fraud_suspected: 2, other: 3 }
      t.text :description, null: false
      t.integer :status, null: false, default: 0 # enum: { open: 0, under_review: 1, resolved: 2, escalated: 3 }
      t.text :resolution, null: true
      t.datetime :opened_at, null: false
      t.datetime :resolved_at, null: true
      t.references :transaction, null: false, foreign_key: { to_table: :trade_transactions }
      t.references :opened_by, null: false, foreign_key: { to_table: :players }
      t.references :resolved_by, null: true, foreign_key: { to_table: :players }

      t.timestamps
    end
  end
end
