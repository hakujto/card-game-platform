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
    raise NotImplementedError, "cancel not implemented"
  end

  def pay(payment_ref)
    raise NotImplementedError, "pay not implemented"
  end

  def calculate_total
    raise NotImplementedError, "calculate_total not implemented"
  end

  def apply_discount(percent)
    raise NotImplementedError, "apply_discount not implemented"
  end

  def refund
    raise NotImplementedError, "refund not implemented"
  end

  def notify_shipped
    raise NotImplementedError, "notify_shipped not implemented"
  end
end
