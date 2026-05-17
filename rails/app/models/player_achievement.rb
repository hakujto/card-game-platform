class PlayerAchievement < ApplicationRecord
  self.table_name = 'player_achievements'

  belongs_to :player, class_name: 'Player'
  belongs_to :achievement, class_name: 'Achievement'

  # Domain invariants — IMPLIES rules
  validate :validate_implies

  def validate_implies
    errors.add(:base, 'Completed achievement must have progress greater than zero') if (is_completed == true) && !((progress.nil? || progress > 0))
  end

  def to_s
    earned_at.to_s
  end
end
