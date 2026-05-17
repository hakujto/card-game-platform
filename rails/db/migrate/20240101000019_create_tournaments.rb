class CreateTournaments < ActiveRecord::Migration[7.1]
  def change
    create_table :tournaments do |t|
      t.string :name, limit: 200, null: false
      t.text :description, null: true
      t.integer :format, null: false, default: 0 # enum: { standard: 0, extended: 1, legacy: 2, vintage: 3, commander: 4, draft: 5 }
      t.integer :tournament_type, null: false, default: 0 # enum: { swiss: 0, single_elimination: 1, double_elimination: 2, round_robin: 3 }
      t.integer :status, null: false, default: 0 # enum: { draft: 0, registration: 1, ongoing: 2, completed: 3, cancelled: 4 }
      t.integer :max_players, null: false
      t.decimal :entry_fee, precision: 10, scale: 2, null: false, default: 0
      t.decimal :prize_pool, precision: 10, scale: 2, null: false, default: 0
      t.datetime :start_time, null: false
      t.datetime :end_time, null: true
      t.boolean :is_online, null: false, default: true
      t.string :location, limit: 300, null: true
      t.text :rules_text, null: true
      t.references :season, null: false, foreign_key: { to_table: :seasons }
      t.references :organizer, null: false, foreign_key: { to_table: :players }

      t.timestamps
    end
  end
end
