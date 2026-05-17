class CreateDraftSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :draft_sessions do |t|
      t.integer :status, null: false, default: 0 # enum: { waiting_for_players: 0, drafting: 1, completed: 2, abandoned: 3 }
      t.integer :draft_type, null: false, default: 0 # enum: { booster: 0, cube: 1, rochester: 2 }
      t.integer :seats, null: false, default: 8
      t.datetime :completed_at, null: true
      t.references :card_set, null: false, foreign_key: { to_table: :card_sets }

      t.timestamps
    end
  end
end
