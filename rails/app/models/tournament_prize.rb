class TournamentPrize < ApplicationRecord
  self.table_name = 'tournament_prizes'

  enum :prize_type, { currency: 0, cards: 1, booster_packs: 2, trophy: 3, season_points: 4, mixed: 5 }

  belongs_to :tournament, class_name: 'Tournament'

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:placement_range_valid, 'placement_to must be greater than or equal to placement_from') unless ((placement_to.nil? || (!placement_from.nil? && placement_to >= placement_from)))
    errors.add(:placement_from_positive, 'placement_from must be greater than zero') unless ((placement_from.nil? || placement_from > 0))
    errors.add(:amount_not_negative, 'Prize amount must not be negative') unless ((amount.nil? || amount.to_f >= 0))
  end

  def to_s
    placement_from.to_s
  end

  # Business operations

  def applies_to_placement(placement)
    raise NotImplementedError, "applies_to_placement not implemented"
  end

  def award_to_player(player_id)
    raise NotImplementedError, "award_to_player not implemented"
  end
end
