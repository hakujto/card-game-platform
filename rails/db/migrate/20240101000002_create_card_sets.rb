class CreateCardSets < ActiveRecord::Migration[7.1]
  def change
    create_table :card_sets do |t|
      t.string :name, limit: 200, null: false
      t.string :code, limit: 10, null: false
      t.date :release_date, null: false
      t.date :rotation_date, null: true
      t.integer :set_type, null: false, default: 1 # enum: { core: 0, expansion: 1, supplemental: 2, masters: 3, draft: 4 }
      t.integer :total_cards, null: false
      t.boolean :is_rotated, null: false, default: false
      t.text :description, null: true
      t.string :logo_url, limit: 200, null: true

      t.timestamps
    end
  end
end
