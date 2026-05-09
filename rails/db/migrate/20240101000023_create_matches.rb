class CreateMatches < ActiveRecord::Migration[7.1]
  def change
    create_table :matches do |t|
      t.integer :table_number, null: true
      t.integer :status, null: false, default: 0 # enum: { pending: 0, active: 1, completed: 2, b_y_e: 3, draw: 4 }
      t.integer :player1_wins, null: false, default: 0
      t.integer :player2_wins, null: false, default: 0
      t.datetime :started_at, null: true
      t.datetime :ended_at, null: true
      t.text :result_notes, null: true
      t.references :round, null: true, foreign_key: { to_table: :tournament_rounds }
      t.references :player1, null: false, foreign_key: { to_table: :players }
      t.references :player2, null: true, foreign_key: { to_table: :players }
      t.references :games, null: true, foreign_key: { to_table: :games }

      t.timestamps
    end
  end
end
