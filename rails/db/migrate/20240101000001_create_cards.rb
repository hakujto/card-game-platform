class CreateCards < ActiveRecord::Migration[7.1]
  def change
    create_table :cards do |t|
      t.string :name, limit: 200, null: false
      t.integer :card_type, null: false, default: 0 # enum: { creature: 0, spell: 1, land: 2, artifact: 3, enchantment: 4, planeswalker: 5 }
      t.integer :rarity, null: false, default: 0 # enum: { common: 0, uncommon: 1, rare: 2, mythic_rare: 3, legendary: 4 }
      t.integer :mana_cost, null: false, default: 0
      t.integer :mana_colors, null: false, default: 0 # enum: { white: 0, blue: 1, black: 2, red: 3, green: 4, colorless: 5 }
      t.integer :attack, null: true
      t.integer :defense, null: true
      t.integer :loyalty, null: true
      t.text :description, null: false
      t.text :flavor_text, null: true
      t.string :image_url, limit: 200, null: true
      t.string :artist_name, limit: 100, null: true
      t.integer :legal_formats, null: false, default: 0 # enum: { standard: 0, extended: 1, legacy: 2, vintage: 3, commander: 4, draft: 5 }
      t.boolean :is_banned, null: false, default: false
      t.boolean :is_restricted, null: false, default: false
      t.integer :power_level, null: false, default: 1
      t.references :set, null: false, foreign_key: { to_table: :card_sets }
      t.references :rulings, null: true, foreign_key: { to_table: :card_rulings }
      t.references :abilities, null: true, foreign_key: { to_table: :card_abilities }

      t.timestamps
    end
  end
end
