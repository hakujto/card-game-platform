class Order < ApplicationRecord
  self.table_name = 'orders'

  enum :status, { pending: 0, paid: 1, processing: 2, shipped: 3, completed: 4, cancelled: 5, refunded: 6 }, prefix: :status
  enum :payment_method, { card: 0, pay_pal: 1, crypto: 2, platform_credits: 3 }, prefix: :payment_method

  has_many :items, class_name: 'OrderItem', inverse_of: :order
  belongs_to :player, class_name: 'Player', inverse_of: :orders
  belongs_to :coupon, class_name: 'Coupon', inverse_of: :orders, optional: true

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

  # Lifecycle hooks
  before_create :assign_currency_default
  after_update :notify_status_change

  def assign_currency_default
    # TODO: implement assign_currency_default
  end

  def notify_status_change
    # TODO: implement notify_status_change
  end

  def as_json(options = {})
    hash = super(options)
    hash['createdAt'] = hash.delete('created_at') if hash.key?('created_at')
    hash['paidAt'] = hash.delete('paid_at') if hash.key?('paid_at')
    hash['shippedAt'] = hash.delete('shipped_at') if hash.key?('shipped_at')
    hash
  end
end
