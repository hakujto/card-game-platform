class PlayerSeasonStats < ApplicationRecord
  self.table_name = 'player_season_statses'

  enum :highest_rank, { bronze: 0, silver: 1, gold: 2, platinum: 3, diamond: 4, master: 5, grandmaster: 6 }

  belongs_to :player, class_name: 'Player'
  belongs_to :season, class_name: 'Season'

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:wins_not_negative, 'Season wins must not be negative') unless ((wins.nil? || wins >= 0))
    errors.add(:losses_not_negative, 'Season losses must not be negative') unless ((losses.nil? || losses >= 0))
    errors.add(:tournament_wins_not_negative, 'Season tournament wins must not be negative') unless ((tournament_wins.nil? || tournament_wins >= 0))
    errors.add(:season_points_not_negative, 'Season points must not be negative') unless ((season_points.nil? || season_points >= 0))
  end

  def to_s
    wins.to_s
  end

  # Business operations

  def win_rate
    raise NotImplementedError, "win_rate not implemented"
  end

  def add_points(points)
    raise NotImplementedError, "add_points not implemented"
  end

  def record_tournament_win
    raise NotImplementedError, "record_tournament_win not implemented"
  end
end
