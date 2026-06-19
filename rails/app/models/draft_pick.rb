class DraftPick < ApplicationRecord
  self.table_name = 'draft_picks'

  belongs_to :participant, class_name: 'DraftParticipant', inverse_of: :picks
  belongs_to :card, class_name: 'Card', inverse_of: :draft_picks

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:pick_number_positive, 'Pick number must be greater than zero') unless ((pick_number.nil? || pick_number > 0))
    errors.add(:pack_number_range, 'Pack number must be between 1 and 3') unless ((pack_number.nil? || (pack_number >= 1 && pack_number <= 3)))
  end

  def to_s
    pick_number.to_s
  end

  # Business operations

  def is_first_pick
    # TODO: implement is_first_pick
    nil
  end

  def as_json(options = {})
    hash = super(options)
    hash['pickedAt'] = hash.delete('picked_at') if hash.key?('picked_at')
    hash
  end
end
