class CreateDecks < ActiveRecord::Migration[7.1]
  def change
    create_table :decks do |t|
      t.string :name, limit: 100, null: false
      t.text :description, null: true
      t.integer :format, null: false, default: 0 # enum: { standard: 0, extended: 1, legacy: 2, vintage: 3, commander: 4, draft: 5 }
      t.boolean :is_public, null: false, default: false
      t.boolean :is_tournament_legal, null: false, default: false
      t.integer :archetype, null: true # enum: { aggro: 0, control: 1, midrange: 2, combo: 3, prison: 4, tempo: 5 }
      t.integer :wins, null: false, default: 0
      t.integer :losses, null: false, default: 0
      t.integer :draws, null: false, default: 0
      t.references :player, null: false, foreign_key: { to_table: :players }

      t.timestamps
    end
  end
end
