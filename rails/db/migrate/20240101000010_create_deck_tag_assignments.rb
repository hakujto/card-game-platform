class CreateDeckTagAssignments < ActiveRecord::Migration[7.1]
  def change
    create_table :deck_tag_assignments do |t|
      t.references :deck, null: false, foreign_key: { to_table: :decks, on_delete: :cascade }
      t.references :tag, null: false, foreign_key: { to_table: :deck_tags, on_delete: :cascade }

      t.timestamps
    end
  end
end
