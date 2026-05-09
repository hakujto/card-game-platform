class Coupon < ApplicationRecord
  self.table_name = 'coupons'

  enum :discount_type, { percent: 0, fixed: 1 }

  validates :code, presence: true, length: { maximum: 50 }

  def to_s
    code.to_s
  end
end
