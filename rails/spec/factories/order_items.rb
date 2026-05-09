FactoryBot.define do
  factory :order_item do
    quantity { 1 }
    price_at_purchase { '0.00' }
    foil { true }
  end
end
