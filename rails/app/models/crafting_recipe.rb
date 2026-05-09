class CraftingRecipe < ApplicationRecord
  self.table_name = 'crafting_recipes'

  belongs_to :result_card, class_name: 'Card'
  has_many :required_cards, class_name: 'Card', through: :crafting_ingredients

  def to_s
    dust_cost.to_s
  end
end
