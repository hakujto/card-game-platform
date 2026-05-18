class Product < ApplicationRecord
  self.table_name = 'products'

  enum :product_type, { single_card: 0, booster_pack: 1, bundle: 2, preconstructed_deck: 3, accessory: 4 }

  belongs_to :card, class_name: 'Card', optional: true
  belongs_to :card_set, class_name: 'CardSet', optional: true

  validates :name, presence: true, length: { maximum: 200 }

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:price_positive, 'Product price must be greater than zero') unless ((price.nil? || price.to_f > 0))
    errors.add(:stock_not_negative, 'Product stock must not be negative') unless ((stock.nil? || stock >= 0))
    errors.add(:discount_percent_range, 'Product discount percent must be between 0 and 100') unless ((discount_percent.nil? || (discount_percent >= 0 && discount_percent <= 100)))
  end

  def to_s
    name.to_s
  end

  # Business operations

  def activate
    raise NotImplementedError, "activate not implemented"
  end

  def deactivate
    raise NotImplementedError, "deactivate not implemented"
  end

  def apply_discount(percent)
    raise NotImplementedError, "apply_discount not implemented"
  end

  def restock(quantity)
    raise NotImplementedError, "restock not implemented"
  end

  def effective_price
    raise NotImplementedError, "effective_price not implemented"
  end

  def is_in_stock
    raise NotImplementedError, "is_in_stock not implemented"
  end
end
