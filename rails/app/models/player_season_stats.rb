class PlayerSeasonStats < ApplicationRecord
  self.table_name = 'player_season_statses'

  enum :highest_rank, { bronze: 0, silver: 1, gold: 2, platinum: 3, diamond: 4, master: 5, grandmaster: 6 }

  belongs_to :player, class_name: 'Player'
  belongs_to :season, class_name: 'Season'

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
