class CraftingIngredient < ApplicationRecord
  self.table_name = 'crafting_ingredients'

  belongs_to :recipe, class_name: 'CraftingRecipe', inverse_of: :ingredients
  belongs_to :card, class_name: 'Card', inverse_of: :used_in_recipes

  def to_s
    quantity.to_s
  end
end
