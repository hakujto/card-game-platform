class Coupon < ApplicationRecord
  self.table_name = 'coupons'

  enum :discount_type, { percent: 0, fixed: 1 }

  validates :code, presence: true, length: { maximum: 50 }

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:valid_until_after_valid_from, 'Coupon expiry must be after its start date') unless ((valid_until.nil? || (!valid_from.nil? && valid_until > valid_from)))
    errors.add(:discount_value_positive, 'Discount value must be greater than zero') unless ((discount_value.nil? || discount_value.to_f > 0))
  end

  # Domain invariants — IMPLIES rules
  validate :validate_implies

  def validate_implies
    errors.add(:base, 'Percent discount must be between 1 and 100') if (discount_type == 'percent') && !((discount_value.nil? || (discount_value >= 1 && discount_value <= 100)))
    errors.add(:base, 'Coupon uses count cannot exceed max_uses') if (!max_uses.nil?) && !((uses_count.nil? || (!max_uses.nil? && uses_count <= max_uses)))
  end

  def to_s
    code.to_s
  end

  # Business operations

  def is_valid
    raise NotImplementedError, "is_valid not implemented"
  end

  def is_applicable_to_order(order_total)
    raise NotImplementedError, "is_applicable_to_order not implemented"
  end

  def redeem
    raise NotImplementedError, "redeem not implemented"
  end

  def deactivate
    raise NotImplementedError, "deactivate not implemented"
  end
end
