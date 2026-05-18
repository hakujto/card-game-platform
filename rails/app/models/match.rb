class Match < ApplicationRecord
  self.table_name = 'matches'

  enum :status, { pending: 0, active: 1, completed: 2, b_y_e: 3, draw: 4 }

  belongs_to :round, class_name: 'TournamentRound'
  belongs_to :player1, class_name: 'Player'
  belongs_to :player2, class_name: 'Player', optional: true

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:wins_not_negative, 'Win counts must not be negative') unless (((player1_wins.nil? || player1_wins >= 0) && (player2_wins.nil? || player2_wins >= 0)))
    errors.add(:max_three_games, 'Win counts cannot exceed 2 in a best-of-3 match') unless (((player1_wins.nil? || (player1_wins >= 0 && player1_wins <= 2)) && (player2_wins.nil? || (player2_wins >= 0 && player2_wins <= 2))))
  end

  # Domain invariants — IMPLIES rules
  validate :validate_implies

  def validate_implies
    errors.add(:base, 'BYE match must not have a second player') if (status == 'b_y_e') && !player2.nil?
    errors.add(:base, 'Match end time must be after start time') if (!ended_at.nil?) && !((ended_at.nil? || (!started_at.nil? && ended_at > started_at)))
    errors.add(:base, 'Completed match must have a start time') if (status == 'completed') && started_at.nil?
  end

  def to_s
    table_number.to_s
  end

  # Business operations

  def record_result(p1_wins, p2_wins)
    raise NotImplementedError, "record_result not implemented"
  end

  def determine_winner
    raise NotImplementedError, "determine_winner not implemented"
  end

  def concede(player_id)
    raise NotImplementedError, "concede not implemented"
  end

  def draw
    raise NotImplementedError, "draw not implemented"
  end
end
