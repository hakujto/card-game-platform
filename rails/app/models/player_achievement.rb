class PlayerAchievement < ApplicationRecord
  self.table_name = 'player_achievements'

  belongs_to :player, class_name: 'Player'
  belongs_to :achievement, class_name: 'Achievement'

  def to_s
    earned_at.to_s
  end
end
