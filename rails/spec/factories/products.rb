FactoryBot.define do
  factory :product do
    name { 'test' }
    product_type { :single_card }
    price { '0.00' }
    stock { 1 }
    active { true }
  end
end
