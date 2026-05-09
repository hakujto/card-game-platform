FactoryBot.define do
  factory :trade_bid do
    amount { '0.00' }
    placed_at { Time.now }
    is_winning { true }
  end
end
