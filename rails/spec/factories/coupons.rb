FactoryBot.define do
  factory :coupon do
    code { 'test' }
    discount_type { :percent }
    discount_value { '0.00' }
    min_order_value { '0.00' }
    uses_count { 1 }
  end
end
