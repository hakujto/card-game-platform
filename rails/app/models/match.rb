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
    # TODO: implement record_result
  end

  def finalize_result
    # TODO: implement finalize_result
  end

  def determine_winner
    # TODO: implement determine_winner
    nil
  end

  def concede(player_id)
    # TODO: implement concede
  end

  def draw
    # TODO: implement draw
  end

  # Lifecycle state machine
  ALLOWED_TRANSITIONS = {
    'pending' => ['active', 'b_y_e'],
    'active' => ['completed', 'draw'],
  }.freeze

  def assert_transition!(to_state)
    allowed = ALLOWED_TRANSITIONS.fetch(status.to_s, [])
    unless allowed.include?(to_state.to_s)
      raise ArgumentError, "Transition #{status} -> #{to_state} not allowed"
    end
  end

  def as_json(options = {})
    hash = super(options)
    hash['startedAt'] = hash.delete('started_at') if hash.key?('started_at')
    hash['endedAt'] = hash.delete('ended_at') if hash.key?('ended_at')
    hash
  end
end
