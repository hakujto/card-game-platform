FactoryBot.define do
  factory :order do
    status { :pending }
    total { '0.00' }
    discount_applied { '0.00' }
    currency { 'test' }
    created_at { Time.now }
  end
end
