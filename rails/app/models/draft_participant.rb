class DraftParticipant < ApplicationRecord
  self.table_name = 'draft_participants'

  belongs_to :session, class_name: 'DraftSession'
  belongs_to :player, class_name: 'Player'

  def to_s
    seat_number.to_s
  end

  # Business operations

  def pick_card(card_id, pack_number)
    raise NotImplementedError, "pick_card not implemented"
  end

  def drafted_card_count
    raise NotImplementedError, "drafted_card_count not implemented"
  end
end
