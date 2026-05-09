class CreateDeckSideboardCards < ActiveRecord::Migration[7.1]
  def change
    create_table :deck_sideboard_cards do |t|
      t.integer :quantity, null: false, default: 1
      t.references :deck, null: false, foreign_key: { to_table: :decks }
      t.references :card, null: false, foreign_key: { to_table: :cards }

      t.timestamps
    end
  end
end
