class Product < ApplicationRecord
  self.table_name = 'products'

  enum :product_type, { single_card: 0, booster_pack: 1, bundle: 2, preconstructed_deck: 3, accessory: 4 }

  has_many :order_items, class_name: 'OrderItem', inverse_of: :product
  belongs_to :card, class_name: 'Card', inverse_of: :shop_product, optional: true
  belongs_to :card_set, class_name: 'CardSet', inverse_of: :shop_products, optional: true

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
    # TODO: implement activate
  end

  def deactivate
    # TODO: implement deactivate
  end

  def apply_discount(percent)
    # TODO: implement apply_discount
    nil
  end

  def restock(quantity)
    # TODO: implement restock
  end

  def effective_price
    # TODO: implement effective_price
    nil
  end

  def is_in_stock
    # TODO: implement is_in_stock
    nil
  end
end
