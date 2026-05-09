class DraftParticipant < ApplicationRecord
  self.table_name = 'draft_participants'

  belongs_to :session, class_name: 'DraftSession', optional: true
  belongs_to :player, class_name: 'Player'
  belongs_to :drafted_cards, class_name: 'DraftPick', optional: true

  def to_s
    seat_number.to_s
  end
end
