class Tournament < ApplicationRecord
  self.table_name = 'tournaments'

  enum :format, { standard: 0, extended: 1, legacy: 2, vintage: 3, commander: 4, draft: 5 }, prefix: :format
  enum :tournament_type, { swiss: 0, single_elimination: 1, double_elimination: 2, round_robin: 3 }, prefix: :tournament_type
  enum :status, { draft: 0, registration: 1, ongoing: 2, completed: 3, cancelled: 4 }, prefix: :status

  belongs_to :season, class_name: 'Season'
  belongs_to :organizer, class_name: 'Player'
  belongs_to :registrations, class_name: 'TournamentRegistration', optional: true
  belongs_to :rounds, class_name: 'TournamentRound', optional: true
  belongs_to :prizes, class_name: 'TournamentPrize', optional: true
  has_many :judges, class_name: 'Player', through: :tournament_judges

  validates :name, presence: true, length: { maximum: 200 }

  def to_s
    name.to_s
  end
end
