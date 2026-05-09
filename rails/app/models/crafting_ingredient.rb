class CraftingIngredient < ApplicationRecord
  self.table_name = 'crafting_ingredients'

  belongs_to :recipe, class_name: 'CraftingRecipe'
  belongs_to :card, class_name: 'Card'

  def to_s
    quantity.to_s
  end
end
