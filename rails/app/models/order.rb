class Order < ApplicationRecord
  self.table_name = 'orders'

  enum :status, { pending: 0, paid: 1, processing: 2, shipped: 3, completed: 4, cancelled: 5, refunded: 6 }, prefix: :status
  enum :payment_method, { card: 0, pay_pal: 1, crypto: 2, platform_credits: 3 }, prefix: :payment_method

  belongs_to :player, class_name: 'Player'
  belongs_to :coupon, class_name: 'Coupon', optional: true

  validates :currency, presence: true, length: { maximum: 3 }

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:total_not_negative, 'Order total must not be negative') unless ((total.nil? || total.to_f >= 0))
    errors.add(:discount_not_exceed_total, 'Discount applied cannot exceed order total') unless ((discount_applied.nil? || (!total.nil? && discount_applied.to_f <= total.to_f)))
  end

  # Domain invariants — IMPLIES rules
  validate :validate_implies

  def validate_implies
    errors.add(:base, 'Paid order must have paid_at set') if (status == 'paid') && paid_at.nil?
    errors.add(:base, 'Shipped order must have a tracking number') if (status == 'shipped') && tracking_number.nil?
    errors.add(:base, 'shipped_at_requires_shipped_status') if (!shipped_at.nil?) && !(status == 'shipped')
  end

  def to_s
    status.to_s
  end

  # Business operations

  def cancel
    # TODO: implement cancel
  end

  def pay(payment_ref)
    # TODO: implement pay
    nil
  end

  def process_payment
    # TODO: implement process_payment
    nil
  end

  def calculate_total
    # TODO: implement calculate_total
    nil
  end

  def apply_discount(percent)
    # TODO: implement apply_discount
    nil
  end

  def refund
    # TODO: implement refund
  end

  def notify_shipped
    # TODO: implement notify_shipped
  end

  # Lifecycle state machine
  ALLOWED_TRANSITIONS = {
    'pending' => ['paid', 'cancelled'],
    'paid' => ['processing', 'cancelled'],
    'processing' => ['shipped'],
    'shipped' => ['completed'],
    'completed' => ['refunded'],
  }.freeze

  def assert_transition!(to_state)
    allowed = ALLOWED_TRANSITIONS.fetch(status.to_s, [])
    unless allowed.include?(to_state.to_s)
      raise ArgumentError, "Transition #{status} -> #{to_state} not allowed"
    end
  end
end
