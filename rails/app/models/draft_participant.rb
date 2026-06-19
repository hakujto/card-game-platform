class DraftParticipant < ApplicationRecord
  self.table_name = 'draft_participants'

  has_many :picks, class_name: 'DraftPick', inverse_of: :participant
  belongs_to :session, class_name: 'DraftSession', inverse_of: :participants
  belongs_to :player, class_name: 'Player', inverse_of: :draft_sessions

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
    # TODO: implement pick_card
  end

  def drafted_card_count
    # TODO: implement drafted_card_count
    nil
  end

  def as_json(options = {})
    hash = super(options)
    hash['joinedAt'] = hash.delete('joined_at') if hash.key?('joined_at')
    hash
  end
end
