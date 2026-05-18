class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.integer :game_number, null: false
      t.integer :winner_side, null: true # enum: { player1: 0, player2: 1, draw: 2 }
      t.integer :turns_played, null: true
      t.integer :duration_seconds, null: true
      t.integer :ended_by, null: true # enum: { normal: 0, timeout: 1, concession: 2, draw_offer: 3 }
      t.string :replay_url, limit: 200, null: true
      t.references :match, null: false, foreign_key: { to_table: :matches }
      t.references :winner, null: true, foreign_key: { to_table: :players }

      t.timestamps
    end
  end
end
