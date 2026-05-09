class Match < ApplicationRecord
  self.table_name = 'matches'

  enum :status, { pending: 0, active: 1, completed: 2, b_y_e: 3, draw: 4 }

  belongs_to :round, class_name: 'TournamentRound', optional: true
  belongs_to :player1, class_name: 'Player'
  belongs_to :player2, class_name: 'Player', optional: true
  belongs_to :games, class_name: 'Game', optional: true

  def to_s
    table_number.to_s
  end
end
