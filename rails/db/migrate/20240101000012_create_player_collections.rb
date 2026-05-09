class CreatePlayerCollections < ActiveRecord::Migration[7.1]
  def change
    create_table :player_collections do |t|
      t.integer :quantity, null: false, default: 1
      t.boolean :foil, null: false, default: false
      t.integer :condition, null: false, default: 0 # enum: { mint: 0, near_mint: 1, excellent: 2, good: 3, played: 4 }
      t.datetime :acquired_at, null: false
      t.integer :acquired_via, null: false, default: 0 # enum: { purchase: 0, trade: 1, tournament_reward: 2, pack: 3, craft: 4 }
      t.references :player, null: false, foreign_key: { to_table: :players }
      t.references :card, null: false, foreign_key: { to_table: :cards }

      t.timestamps
    end
  end
end
