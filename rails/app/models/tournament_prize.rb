class TournamentPrize < ApplicationRecord
  self.table_name = 'tournament_prizes'

  enum :prize_type, { currency: 0, cards: 1, booster_packs: 2, trophy: 3, season_points: 4, mixed: 5 }

  belongs_to :tournament, class_name: 'Tournament'

  def to_s
    placement_from.to_s
  end
end
