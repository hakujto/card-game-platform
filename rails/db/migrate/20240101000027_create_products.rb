class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name, limit: 200, null: false
      t.integer :product_type, null: false, default: 0 # enum: { single_card: 0, booster_pack: 1, bundle: 2, preconstructed_deck: 3, accessory: 4 }
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :stock, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.integer :discount_percent, null: false, default: 0
      t.text :description, null: true
      t.string :image_url, limit: 200, null: true
      t.boolean :featured, null: false, default: false
      t.references :card, null: true, foreign_key: { to_table: :cards }
      t.references :card_set, null: true, foreign_key: { to_table: :card_sets }

      t.timestamps
    end
  end
end
