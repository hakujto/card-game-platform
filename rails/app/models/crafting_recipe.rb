class CraftingRecipe < ApplicationRecord
  self.table_name = 'crafting_recipes'

  belongs_to :result_card, class_name: 'Card'
  has_many :required_cards, class_name: 'Card', through: :crafting_ingredients

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:dust_cost_positive, 'Crafting recipe must have a dust cost greater than zero') unless ((dust_cost.nil? || dust_cost > 0))
  end

  def to_s
    dust_cost.to_s
  end

  # Business operations

  def can_craft(player_id)
    raise NotImplementedError, "can_craft not implemented"
  end

  def execute_craft(player_id)
    raise NotImplementedError, "execute_craft not implemented"
  end

  def disable
    raise NotImplementedError, "disable not implemented"
  end

  def enable
    raise NotImplementedError, "enable not implemented"
  end
end
