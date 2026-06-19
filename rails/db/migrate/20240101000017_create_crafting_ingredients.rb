class CreateCraftingIngredients < ActiveRecord::Migration[7.1]
  def change
    create_table :crafting_ingredients do |t|
      t.integer :quantity, null: false, default: 1
      t.references :recipe, null: false, foreign_key: { to_table: :crafting_recipes, on_delete: :cascade }
      t.references :card, null: false, foreign_key: { to_table: :cards, on_delete: :restrict }

      t.timestamps
    end
  end
end
