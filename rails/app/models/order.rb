class Order < ApplicationRecord
  self.table_name = 'orders'

  enum :status, { pending: 0, paid: 1, processing: 2, shipped: 3, completed: 4, cancelled: 5, refunded: 6 }, prefix: :status
  enum :payment_method, { card: 0, pay_pal: 1, crypto: 2, platform_credits: 3 }, prefix: :payment_method

  belongs_to :player, class_name: 'Player'
  belongs_to :items, class_name: 'OrderItem'
  belongs_to :coupon, class_name: 'Coupon', optional: true

  validates :currency, presence: true, length: { maximum: 3 }

  def to_s
    status.to_s
  end
end
