class DraftSession < ApplicationRecord
  self.table_name = 'draft_sessions'

  enum :status, { waiting_for_players: 0, drafting: 1, completed: 2, abandoned: 3 }, prefix: :status
  enum :draft_type, { booster: 0, cube: 1, rochester: 2 }, prefix: :draft_type

  belongs_to :card_set, class_name: 'CardSet'

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:seats_range, 'Draft session must have between 2 and 16 seats') unless ((seats.nil? || (seats >= 2 && seats <= 16)))
  end

  # Domain invariants — IMPLIES rules
  validate :validate_implies

  def validate_implies
    errors.add(:base, 'completed_at can only be set when draft status is Completed') if (!completed_at.nil?) && !(status == 'completed')
  end

  def to_s
    status.to_s
  end

  # Business operations

  def start
    raise NotImplementedError, "start not implemented"
  end

  def abandon
    raise NotImplementedError, "abandon not implemented"
  end

  def complete
    raise NotImplementedError, "complete not implemented"
  end

  def is_full
    raise NotImplementedError, "is_full not implemented"
  end
end
