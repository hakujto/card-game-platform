class CreateTournamentRounds < ActiveRecord::Migration[7.1]
  def change
    create_table :tournament_rounds do |t|
      t.integer :round_number, null: false
      t.integer :status, null: false, default: 0 # enum: { pending: 0, active: 1, completed: 2 }
      t.datetime :started_at, null: true
      t.datetime :ended_at, null: true
      t.integer :time_limit_minutes, null: false, default: 50
      t.references :tournament, null: false, foreign_key: { to_table: :tournaments }
      t.references :matches, null: false, foreign_key: { to_table: :matches }

      t.timestamps
    end
  end
end
