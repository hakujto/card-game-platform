FactoryBot.define do
  factory :trade_dispute do
    status { :open }
    reason { :item_not_received }
    description { 'test' }
    opened_at { Time.now }
  end
end
