class TournamentRegistration < ApplicationRecord
  self.table_name = 'tournament_registrations'

  enum :status, { registered: 0, waitlisted: 1, withdrawn: 2, disqualified: 3 }

  belongs_to :tournament, class_name: 'Tournament'
  belongs_to :player, class_name: 'Player'
  belongs_to :deck, class_name: 'Deck'

  def to_s
    status.to_s
  end
end
