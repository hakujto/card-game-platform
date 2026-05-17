class Game < ApplicationRecord
  self.table_name = 'games'

  enum :winner_side, { player1: 0, player2: 1, draw: 2 }, prefix: :winner_side
  enum :ended_by, { normal: 0, timeout: 1, concession: 2, draw_offer: 3 }, prefix: :ended_by

  belongs_to :match, class_name: 'Match'
  belongs_to :winner, class_name: 'Player', optional: true

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:game_number_range, 'Game number must be between 1 and 3 (best-of-3)') unless ((game_number.nil? || (game_number >= 1 && game_number <= 3)))
  end

  # Domain invariants — IMPLIES rules
  validate :validate_implies

  def validate_implies
    errors.add(:base, 'Turns played must be greater than zero') if (!turns_played.nil?) && !((turns_played.nil? || turns_played > 0))
    errors.add(:base, 'Game duration must be greater than zero') if (!duration_seconds.nil?) && !((duration_seconds.nil? || duration_seconds > 0))
  end

  def to_s
    game_number.to_s
  end

  # Business operations

  def record_winner(winner_side)
    raise NotImplementedError, "record_winner not implemented"
  end

  def duration_minutes
    raise NotImplementedError, "duration_minutes not implemented"
  end
end
