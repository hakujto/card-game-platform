class CreateCardRulings < ActiveRecord::Migration[7.1]
  def change
    create_table :card_rulings do |t|
      t.text :ruling_text, null: false
      t.date :published_at, null: false
      t.string :source, limit: 200, null: false
      t.references :card, null: false, foreign_key: { to_table: :cards }

      t.timestamps
    end
  end
end
