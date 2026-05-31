class DraftSession < ApplicationRecord
  self.table_name = 'draft_sessions'

  enum :status, { waiting_for_players: 0, drafting: 1, completed: 2, abandoned: 3 }, prefix: :status
  enum :draft_type, { booster: 0, cube: 1, rochester: 2 }, prefix: :draft_type

  belongs_to :card_set, class_name: 'CardSet'

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:seats_range, 'Draft session must have between 2 and 16 seats') unless ((seats.nil? || (seats >= 2 && seats <= 16)))
    errors.add(:time_per_pick_positive, 'Time per pick must be greater than zero') unless ((time_per_pick_seconds.nil? || time_per_pick_seconds > 0))
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
    # TODO: implement start
  end

  def abandon
    # TODO: implement abandon
  end

  def complete
    # TODO: implement complete
  end

  def is_full
    # TODO: implement is_full
    nil
  end

  # Lifecycle state machine
  ALLOWED_TRANSITIONS = {
    'waiting_for_players' => ['drafting', 'abandoned'],
    'drafting' => ['completed', 'abandoned'],
  }.freeze

  def assert_transition!(to_state)
    allowed = ALLOWED_TRANSITIONS.fetch(status.to_s, [])
    unless allowed.include?(to_state.to_s)
      raise ArgumentError, "Transition #{status} -> #{to_state} not allowed"
    end
  end

  def as_json(options = {})
    hash = super(options)
    hash['createdAt'] = hash.delete('created_at') if hash.key?('created_at')
    hash['completedAt'] = hash.delete('completed_at') if hash.key?('completed_at')
    hash
  end
end
