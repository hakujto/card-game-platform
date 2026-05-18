class DeckSideboardCard < ApplicationRecord
  self.table_name = 'deck_sideboard_cards'

  belongs_to :deck, class_name: 'Deck'
  belongs_to :card, class_name: 'Card'

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:quantity_range, 'Sideboard card quantity must be between 1 and 4 copies') unless ((quantity.nil? || (quantity >= 1 && quantity <= 4)))
  end

  def to_s
    quantity.to_s
  end

  # Business operations

  def increment(amount)
    raise NotImplementedError, "increment not implemented"
  end

  def decrement(amount)
    raise NotImplementedError, "decrement not implemented"
  end
end
