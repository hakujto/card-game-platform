class CardAbility < ApplicationRecord
  self.table_name = 'card_abilities'

  enum :ability_type, { keyword: 0, activated: 1, triggered: 2, static: 3 }, prefix: :ability_type
  enum :timing, { any: 0, sorcery: 1, instant: 2, combat: 3 }, prefix: :timing

  belongs_to :card, class_name: 'Card'

  def to_s
    ability_type.to_s
  end
end
