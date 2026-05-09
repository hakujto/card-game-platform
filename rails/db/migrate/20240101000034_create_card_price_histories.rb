class CreateCardPriceHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :card_price_histories do |t|
      t.date :price_date, null: false
      t.decimal :avg_price, precision: 10, scale: 2, null: false
      t.decimal :min_price, precision: 10, scale: 2, null: false
      t.decimal :max_price, precision: 10, scale: 2, null: false
      t.integer :volume, null: false
      t.boolean :foil, null: false, default: false
      t.references :card, null: false, foreign_key: { to_table: :cards }

      t.timestamps
    end
  end
end
