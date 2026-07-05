class CreatePlayerAchievements < ActiveRecord::Migration[7.1]
  def change
    create_table :player_achievements do |t|
      t.datetime :earned_at, null: false
      t.integer :progress, null: false, default: 0
      t.boolean :is_completed, null: false, default: false
      t.references :player, null: false, foreign_key: { to_table: :players, on_delete: :cascade }
      t.references :achievement, null: false, foreign_key: { to_table: :achievements, on_delete: :restrict }

      t.timestamps
    end
  end
end
