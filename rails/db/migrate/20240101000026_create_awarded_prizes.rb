class CreateAwardedPrizes < ActiveRecord::Migration[7.1]
  def change
    create_table :awarded_prizes do |t|
      t.integer :final_placement, null: false
      t.datetime :awarded_at, null: false
      t.boolean :claimed, null: false, default: false
      t.datetime :claimed_at, null: true
      t.references :prize, null: false, foreign_key: { to_table: :tournament_prizes }
      t.references :player, null: false, foreign_key: { to_table: :players }

      t.timestamps
    end
  end
end
