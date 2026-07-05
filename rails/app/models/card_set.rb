class CardSet < ApplicationRecord
  self.table_name = 'card_sets'

  enum :set_type, { core: 0, expansion: 1, supplemental: 2, masters: 3, draft: 4 }

  has_many :cards, class_name: 'Card', inverse_of: :set
  has_many :shop_products, class_name: 'Product', inverse_of: :card_set
  has_many :draft_sessions, class_name: 'DraftSession', inverse_of: :card_set

  validates :name, presence: true, length: { maximum: 200 }
  validates :code, presence: true, length: { maximum: 10 }
  validates :code, format: { with: /[A-Z]{2,6}/ }
  validates :code, uniqueness: { message: 'code must be unique' }

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:total_cards_positive, 'Card set must have at least one card') unless ((total_cards.nil? || total_cards > 0))
  end

  # Domain invariants — IMPLIES rules
  validate :validate_implies

  def validate_implies
    errors.add(:base, 'Rotation date must be after release date') if (!rotation_date.nil?) && !((rotation_date.nil? || (!release_date.nil? && rotation_date > release_date)))
    errors.add(:base, 'Rotated set must have a rotation date') if (is_rotated == true) && rotation_date.nil?
  end

  def to_s
    name.to_s
  end

  # Business operations

  def is_legal_in_standard
    # TODO: implement is_legal_in_standard
    nil
  end

  def is_legal_in_format(format)
    # TODO: implement is_legal_in_format
    nil
  end

  def card_count_by_rarity(rarity)
    # TODO: implement card_count_by_rarity
    nil
  end

  def rotate_out
    # TODO: implement rotate_out
  end
end
