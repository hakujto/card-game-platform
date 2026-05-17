class TournamentRound < ApplicationRecord
  self.table_name = 'tournament_rounds'

  enum :status, { pending: 0, active: 1, completed: 2 }

  belongs_to :tournament, class_name: 'Tournament'

  # Domain invariants — IMPLIES rules
  validate :validate_implies

  def validate_implies
    errors.add(:base, 'Round end time must be after start time') if (!ended_at.nil?) && !((ended_at.nil? || (!started_at.nil? && ended_at > started_at)))
  end

  def to_s
    round_number.to_s
  end

  # Business operations

  def start
    raise NotImplementedError, "start not implemented"
  end

  def complete
    raise NotImplementedError, "complete not implemented"
  end

  def generate_pairings
    raise NotImplementedError, "generate_pairings not implemented"
  end

  def is_time_expired
    raise NotImplementedError, "is_time_expired not implemented"
  end
end
