class OrderItem < ApplicationRecord
  self.table_name = 'order_items'

  belongs_to :order, class_name: 'Order'
  belongs_to :product, class_name: 'Product'

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:quantity_positive, 'Order item quantity must be greater than zero') unless ((quantity.nil? || quantity > 0))
    errors.add(:price_not_negative, 'Price at purchase must not be negative') unless ((price_at_purchase.nil? || price_at_purchase.to_f >= 0))
  end

  def to_s
    quantity.to_s
  end

  # Business operations

  def line_total
    raise NotImplementedError, "line_total not implemented"
  end
end
