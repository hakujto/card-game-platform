class Player < ApplicationRecord
  self.table_name = 'players'

  enum :rank, { bronze: 0, silver: 1, gold: 2, platinum: 3, diamond: 4, master: 5, grandmaster: 6 }, prefix: :rank
  enum :preferred_format, { standard: 0, extended: 1, legacy: 2, vintage: 3, commander: 4, draft: 5 }, prefix: :preferred_format

  belongs_to :user, class_name: 'User', optional: true
  belongs_to :season_stats, class_name: 'PlayerSeasonStats'
  has_many :achievements, class_name: 'Achievement', through: :player_achievements
  has_many :friends, class_name: 'Player', through: :friendships

  validates :display_name, presence: true, length: { maximum: 50 }

  def to_s
    display_name.to_s
  end
end
