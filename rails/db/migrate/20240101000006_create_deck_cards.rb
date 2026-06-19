class CreateDeckCards < ActiveRecord::Migration[7.1]
  def change
    create_table :deck_cards do |t|
      t.integer :quantity, null: false, default: 1
      t.boolean :is_commander, null: false, default: false
      t.references :deck, null: false, foreign_key: { to_table: :decks, on_delete: :cascade }
      t.references :card, null: false, foreign_key: { to_table: :cards, on_delete: :restrict }

      t.timestamps
    end
  end
end
