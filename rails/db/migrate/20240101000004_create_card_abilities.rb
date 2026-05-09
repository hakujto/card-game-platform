class CreateCardAbilities < ActiveRecord::Migration[7.1]
  def change
    create_table :card_abilities do |t|
      t.integer :ability_type, null: false, default: 0 # enum: { keyword: 0, activated: 1, triggered: 2, static: 3 }
      t.string :keyword, limit: 100, null: true
      t.text :ability_text, null: false
      t.integer :timing, null: false, default: 0 # enum: { any: 0, sorcery: 1, instant: 2, combat: 3 }
      t.references :card, null: false, foreign_key: { to_table: :cards }

      t.timestamps
    end
  end
end
