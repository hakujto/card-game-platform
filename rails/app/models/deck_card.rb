class DeckCard < ApplicationRecord
  self.table_name = 'deck_cards'

  belongs_to :deck, class_name: 'Deck', inverse_of: :deck_cards
  belongs_to :card, class_name: 'Card', inverse_of: :deck_cards

  validates :quantity, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 4 }
  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:quantity_range, 'A deck can contain between 1 and 4 copies of a card') unless ((quantity.nil? || (quantity >= 1 && quantity <= 4)))
  end

  # Domain invariants — IMPLIES rules
  validate :validate_implies

  def validate_implies
    errors.add(:base, 'Commander card must appear exactly once in the deck') if (is_commander == true) && !(quantity == 1)
  end

  def to_s
    quantity.to_s
  end

  # Business operations

  def increment(amount)
    # TODO: implement increment
  end

  def decrement(amount)
    # TODO: implement decrement
  end
end
