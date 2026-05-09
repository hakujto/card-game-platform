class TournamentRound < ApplicationRecord
  self.table_name = 'tournament_rounds'

  enum :status, { pending: 0, active: 1, completed: 2 }

  belongs_to :tournament, class_name: 'Tournament'
  belongs_to :matches, class_name: 'Match'

  def to_s
    round_number.to_s
  end
end
