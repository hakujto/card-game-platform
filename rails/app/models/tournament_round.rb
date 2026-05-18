class TournamentRound < ApplicationRecord
  self.table_name = 'tournament_rounds'

  enum :status, { pending: 0, active: 1, completed: 2 }

  belongs_to :tournament, class_name: 'Tournament'

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:round_number_positive, 'Round number must be greater than zero') unless ((round_number.nil? || round_number > 0))
    errors.add(:time_limit_positive, 'Round time limit must be greater than zero') unless ((time_limit_minutes.nil? || time_limit_minutes > 0))
  end

  # Domain invariants — IMPLIES rules
  validate :validate_implies

  def validate_implies
    errors.add(:base, 'Round end time must be after start time') if (!ended_at.nil?) && !((ended_at.nil? || (!started_at.nil? && ended_at > started_at)))
    errors.add(:base, 'Completed round must have a start time') if (status == 'completed') && started_at.nil?
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
