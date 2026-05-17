class CreatePlayerSeasonStatses < ActiveRecord::Migration[7.1]
  def change
    create_table :player_season_statses do |t|
      t.integer :wins, null: false, default: 0
      t.integer :losses, null: false, default: 0
      t.integer :draws, null: false, default: 0
      t.integer :tournament_wins, null: false, default: 0
      t.integer :highest_rank, null: false, default: 0 # enum: { bronze: 0, silver: 1, gold: 2, platinum: 3, diamond: 4, master: 5, grandmaster: 6 }
      t.integer :season_points, null: false, default: 0
      t.references :player, null: false, foreign_key: { to_table: :players }
      t.references :season, null: false, foreign_key: { to_table: :seasons }

      t.timestamps
    end
  end
end
