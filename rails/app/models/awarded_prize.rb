class AwardedPrize < ApplicationRecord
  self.table_name = 'awarded_prizes'

  belongs_to :prize, class_name: 'TournamentPrize', inverse_of: :awarded_prizes
  belongs_to :player, class_name: 'Player', inverse_of: :awarded_prizes

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

  # Business operations

  def claim
    # TODO: implement claim
  end

  def as_json(options = {})
    hash = super(options)
    hash['awardedAt'] = hash.delete('awarded_at') if hash.key?('awarded_at')
    hash['claimedAt'] = hash.delete('claimed_at') if hash.key?('claimed_at')
    hash
  end
end
