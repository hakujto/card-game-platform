class AwardedPrize < ApplicationRecord
  self.table_name = 'awarded_prizes'

  belongs_to :prize, class_name: 'TournamentPrize'
  belongs_to :player, class_name: 'Player'

  def to_s
    final_placement.to_s
  end
end
