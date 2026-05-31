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
    # TODO: implement validate_size
    nil
  end

  def add_card(card_id, quantity)
    # TODO: implement add_card
  end

  def remove_card(card_id)
    # TODO: implement remove_card
  end

  def win_rate
    # TODO: implement win_rate
    nil
  end

  def clone
    # TODO: implement clone
    nil
  end

  def publish
    # TODO: implement publish
  end

  def unpublish
    # TODO: implement unpublish
  end

  def certify_tournament_legal
    # TODO: implement certify_tournament_legal
    nil
  end

  # Lifecycle hooks
  after_save :recalculate_tournament_legal

  def recalculate_tournament_legal
    # TODO: implement recalculate_tournament_legal
  end

  def as_json(options = {})
    hash = super(options)
    hash['createdAt'] = hash.delete('created_at') if hash.key?('created_at')
    hash['updatedAt'] = hash.delete('updated_at') if hash.key?('updated_at')
    hash
  end
end
