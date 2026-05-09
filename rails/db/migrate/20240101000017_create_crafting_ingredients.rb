class CreateCraftingIngredients < ActiveRecord::Migration[7.1]
  def change
    create_table :crafting_ingredients do |t|
      t.integer :quantity, null: false, default: 1
      t.references :recipe, null: false, foreign_key: { to_table: :crafting_recipes }
      t.references :card, null: false, foreign_key: { to_table: :cards }

      t.timestamps
    end
  end
end
