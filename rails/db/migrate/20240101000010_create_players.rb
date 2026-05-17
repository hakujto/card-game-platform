class CreatePlayers < ActiveRecord::Migration[7.1]
  def change
    create_table :players do |t|
      t.string :display_name, limit: 50, null: false
      t.integer :rank, null: false, default: 0 # enum: { bronze: 0, silver: 1, gold: 2, platinum: 3, diamond: 4, master: 5, grandmaster: 6 }
      t.integer :rating, null: false, default: 1000
      t.integer :peak_rating, null: false, default: 1000
      t.text :bio, null: true
      t.string :country_code, limit: 2, null: true
      t.string :avatar_url, limit: 200, null: true
      t.integer :preferred_format, null: false, default: 0 # enum: { standard: 0, extended: 1, legacy: 2, vintage: 3, commander: 4, draft: 5 }
      t.boolean :is_verified, null: false, default: false
      t.datetime :last_active_at, null: true
      t.references :user, null: true, foreign_key: false

      t.timestamps
    end
  end
end
