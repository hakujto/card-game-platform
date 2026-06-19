class TournamentRound < ApplicationRecord
  self.table_name = 'tournament_rounds'

  enum :status, { pending: 0, active: 1, completed: 2 }

  has_many :matches, class_name: 'Match', inverse_of: :round
  belongs_to :tournament, class_name: 'Tournament', inverse_of: :rounds

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
    # TODO: implement start
  end

  def complete
    # TODO: implement complete
  end

  def generate_pairings
    # TODO: implement generate_pairings
  end

  def is_time_expired
    # TODO: implement is_time_expired
    nil
  end

  def as_json(options = {})
    hash = super(options)
    hash['startedAt'] = hash.delete('started_at') if hash.key?('started_at')
    hash['endedAt'] = hash.delete('ended_at') if hash.key?('ended_at')
    hash
  end
end
