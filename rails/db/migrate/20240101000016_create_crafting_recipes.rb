class CreateCraftingRecipes < ActiveRecord::Migration[7.1]
  def change
    create_table :crafting_recipes do |t|
      t.integer :dust_cost, null: false
      t.boolean :is_available, null: false, default: true
      t.references :result_card, null: false, foreign_key: { to_table: :cards }

      t.timestamps
    end
  end
end
