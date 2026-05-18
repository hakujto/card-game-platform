class DraftParticipant < ApplicationRecord
  self.table_name = 'draft_participants'

  belongs_to :session, class_name: 'DraftSession'
  belongs_to :player, class_name: 'Player'

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:seat_number_positive, 'Seat number must be greater than zero') unless ((seat_number.nil? || seat_number > 0))
  end

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
