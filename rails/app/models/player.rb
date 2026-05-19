class Player < ApplicationRecord
  self.table_name = 'players'

  enum :rank, { bronze: 0, silver: 1, gold: 2, platinum: 3, diamond: 4, master: 5, grandmaster: 6 }, prefix: :rank
  enum :preferred_format, { standard: 0, extended: 1, legacy: 2, vintage: 3, commander: 4, draft: 5 }, prefix: :preferred_format

  belongs_to :user, class_name: 'User', optional: true
  has_many :achievements, class_name: 'Achievement', through: :player_achievements
  has_many :friends, class_name: 'Player', through: :friendships

  validates :display_name, presence: true, length: { maximum: 50 }

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:rating_range, 'Rating must be between 0 and 9999') unless ((rating.nil? || (rating >= 0 && rating <= 9999)))
    errors.add(:peak_rating_gte_rating, 'Peak rating must be greater than or equal to current rating') unless ((peak_rating.nil? || (!rating.nil? && peak_rating >= rating)))
    errors.add(:display_name_not_empty, 'Display name must not be empty') unless (!display_name.nil?)
  end

  def to_s
    display_name.to_s
  end

  # Business operations

  def promote
    # TODO: implement promote
    nil
  end

  def demote
    # TODO: implement demote
    nil
  end

  def record_win
    # TODO: implement record_win
  end

  def record_loss
    # TODO: implement record_loss
  end

  def win_rate
    # TODO: implement win_rate
    nil
  end

  def verify
    # TODO: implement verify
  end

  def update_rating(delta)
    # TODO: implement update_rating
  end
end
