class Game < ApplicationRecord
  self.table_name = 'games'

  enum :winner_side, { player1: 0, player2: 1, draw: 2 }, prefix: :winner_side
  enum :ended_by, { normal: 0, timeout: 1, concession: 2, draw_offer: 3 }, prefix: :ended_by

  belongs_to :match, class_name: 'Match'
  belongs_to :winner, class_name: 'Player', optional: true

  def to_s
    game_number.to_s
  end
end
