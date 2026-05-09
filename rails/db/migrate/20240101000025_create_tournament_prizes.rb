class CreateTournamentPrizes < ActiveRecord::Migration[7.1]
  def change
    create_table :tournament_prizes do |t|
      t.integer :placement_from, null: false
      t.integer :placement_to, null: false
      t.integer :prize_type, null: false, default: 0 # enum: { currency: 0, cards: 1, booster_packs: 2, trophy: 3, season_points: 4, mixed: 5 }
      t.decimal :amount, precision: 10, scale: 2, null: false, default: 0
      t.text :description, null: true
      t.integer :packs_count, null: true
      t.integer :season_points, null: false, default: 0
      t.references :tournament, null: false, foreign_key: { to_table: :tournaments }

      t.timestamps
    end
  end
end
