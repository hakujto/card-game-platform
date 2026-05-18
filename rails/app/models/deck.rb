class Deck < ApplicationRecord
  self.table_name = 'decks'

  enum :format, { standard: 0, extended: 1, legacy: 2, vintage: 3, commander: 4, draft: 5 }, prefix: :format
  enum :archetype, { aggro: 0, control: 1, midrange: 2, combo: 3, prison: 4, tempo: 5 }, prefix: :archetype

  belongs_to :player, class_name: 'Player'
  has_many :cards, class_name: 'Card', through: :deck_cards
  has_many :sideboard_cards, class_name: 'Card', through: :deck_sideboard_cards
  has_many :tags, class_name: 'DeckTag', through: :deck_tag_assignments

  validates :name, presence: true, length: { maximum: 100 }

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:wins_not_negative, 'Deck wins count must not be negative') unless ((wins.nil? || wins >= 0))
    errors.add(:losses_not_negative, 'Deck losses count must not be negative') unless ((losses.nil? || losses >= 0))
    errors.add(:draws_not_negative, 'Deck draws count must not be negative') unless ((draws.nil? || draws >= 0))
  end

  # Domain invariants — IMPLIES rules
  validate :validate_implies

  def validate_implies
    errors.add(:base, 'Tournament-legal deck must be made public') if (is_tournament_legal == true) && !(is_public == true)
  end

  def to_s
    name.to_s
  end

  # Business operations

  def validate_size
    raise NotImplementedError, "validate_size not implemented"
  end

  def add_card(card_id, quantity)
    raise NotImplementedError, "add_card not implemented"
  end

  def remove_card(card_id)
    raise NotImplementedError, "remove_card not implemented"
  end

  def win_rate
    raise NotImplementedError, "win_rate not implemented"
  end

  def clone
    raise NotImplementedError, "clone not implemented"
  end

  def publish
    raise NotImplementedError, "publish not implemented"
  end

  def unpublish
    raise NotImplementedError, "unpublish not implemented"
  end

  def certify_tournament_legal
    raise NotImplementedError, "certify_tournament_legal not implemented"
  end
end
