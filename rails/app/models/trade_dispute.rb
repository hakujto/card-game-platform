class TradeDispute < ApplicationRecord
  self.table_name = 'trade_disputes'

  enum :status, { open: 0, under_review: 1, resolved: 2, escalated: 3 }, prefix: :status
  enum :reason, { item_not_received: 0, item_not_as_described: 1, fraud_suspected: 2, other: 3 }, prefix: :reason

  belongs_to :transaction_record, class_name: 'TradeTransaction', foreign_key: :transaction_id, inverse_of: :dispute, optional: true
  belongs_to :opened_by, class_name: 'Player', inverse_of: :disputes_opened
  belongs_to :resolved_by, class_name: 'Player', inverse_of: :disputes_resolved, optional: true

  # Domain invariants — IMPLIES rules
  validate :validate_implies

  def validate_implies
    errors.add(:base, 'resolved_at_requires_terminal_status') if (!resolved_at.nil?) && !(status == 'resolved')
  end

  def to_s
    status.to_s
  end

  # Business operations

  def escalate
    # TODO: implement escalate
  end

  def resolve(resolution_text)
    # TODO: implement resolve
  end

  def close_resolved
    # TODO: implement close_resolved
  end

  def review
    # TODO: implement review
  end

  # Lifecycle state machine
  ALLOWED_TRANSITIONS = {
    'open' => ['under_review'],
    'under_review' => ['resolved', 'escalated'],
    'escalated' => ['resolved'],
  }.freeze

  def assert_transition!(to_state)
    allowed = ALLOWED_TRANSITIONS.fetch(status.to_s, [])
    unless allowed.include?(to_state.to_s)
      raise ArgumentError, "Transition #{status} -> #{to_state} not allowed"
    end
  end

  def as_json(options = {})
    hash = super(options)
    hash['openedAt'] = hash.delete('opened_at') if hash.key?('opened_at')
    hash['resolvedAt'] = hash.delete('resolved_at') if hash.key?('resolved_at')
    hash
  end
end
