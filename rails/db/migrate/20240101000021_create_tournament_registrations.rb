class CreateTournamentRegistrations < ActiveRecord::Migration[7.1]
  def change
    create_table :tournament_registrations do |t|
      t.integer :status, null: false, default: 0 # enum: { registered: 0, waitlisted: 1, withdrawn: 2, disqualified: 3 }
      t.integer :seed, null: true
      t.integer :final_standing, null: true
      t.integer :points_earned, null: false, default: 0
      t.datetime :registered_at, null: false
      t.references :tournament, null: false, foreign_key: { to_table: :tournaments }
      t.references :player, null: false, foreign_key: { to_table: :players }
      t.references :deck, null: false, foreign_key: { to_table: :decks }

      t.timestamps
    end
  end
end
