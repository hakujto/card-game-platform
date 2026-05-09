class CreateTournamentJudges < ActiveRecord::Migration[7.1]
  def change
    create_table :tournament_judges do |t|
      t.integer :role, null: false, default: 1 # enum: { head_judge: 0, judge: 1, scorekeeper_judge: 2 }
      t.references :tournament, null: false, foreign_key: { to_table: :tournaments }
      t.references :player, null: false, foreign_key: { to_table: :players }

      t.timestamps
    end
  end
end
