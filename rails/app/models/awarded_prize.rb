class AwardedPrize < ApplicationRecord
  self.table_name = 'awarded_prizes'

  belongs_to :prize, class_name: 'TournamentPrize'
  belongs_to :player, class_name: 'Player'

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:final_placement_positive, 'Final placement must be greater than zero') unless ((final_placement.nil? || final_placement > 0))
  end

  # Domain invariants — IMPLIES rules
  validate :validate_implies

  def validate_implies
    errors.add(:base, 'Claimed prize must have a claimed_at timestamp') if (claimed == true) && claimed_at.nil?
  end

  def to_s
    final_placement.to_s
  end
end
