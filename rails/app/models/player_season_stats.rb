class PlayerSeasonStats < ApplicationRecord
  self.table_name = 'player_season_statses'

  enum :highest_rank, { bronze: 0, silver: 1, gold: 2, platinum: 3, diamond: 4, master: 5, grandmaster: 6 }

  belongs_to :player, class_name: 'Player', optional: true
  belongs_to :season, class_name: 'Season'

  def to_s
    wins.to_s
  end
end
