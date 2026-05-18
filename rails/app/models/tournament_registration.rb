class TournamentRegistration < ApplicationRecord
  self.table_name = 'tournament_registrations'

  enum :status, { registered: 0, waitlisted: 1, withdrawn: 2, disqualified: 3 }

  belongs_to :tournament, class_name: 'Tournament'
  belongs_to :player, class_name: 'Player'
  belongs_to :deck, class_name: 'Deck'

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:points_earned_not_negative, 'Points earned must not be negative') unless ((points_earned.nil? || points_earned >= 0))
  end

  # Domain invariants — IMPLIES rules
  validate :validate_implies

  def validate_implies
    errors.add(:base, 'Final standing must be greater than zero') if (!final_standing.nil?) && !((final_standing.nil? || final_standing > 0))
    errors.add(:base, 'Seed must be greater than zero') if (!seed.nil?) && !((seed.nil? || seed > 0))
  end

  def to_s
    status.to_s
  end

  # Business operations

  def withdraw
    raise NotImplementedError, "withdraw not implemented"
  end

  def disqualify(reason)
    raise NotImplementedError, "disqualify not implemented"
  end

  def promote_from_waitlist
    raise NotImplementedError, "promote_from_waitlist not implemented"
  end
end
