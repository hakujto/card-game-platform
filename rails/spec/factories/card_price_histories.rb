FactoryBot.define do
  factory :card_price_history do
    price_date { Date.today }
    avg_price { '0.00' }
    min_price { '0.00' }
    max_price { '0.00' }
    volume { 1 }
  end
end
