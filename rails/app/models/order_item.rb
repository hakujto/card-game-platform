class OrderItem < ApplicationRecord
  self.table_name = 'order_items'

  belongs_to :order, class_name: 'Order', optional: true
  belongs_to :product, class_name: 'Product'

  def to_s
    quantity.to_s
  end
end
