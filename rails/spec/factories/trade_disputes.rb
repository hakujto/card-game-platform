FactoryBot.define do
  factory :trade_dispute do
    reason { :item_not_received }
    description { 'test' }
    status { :open }
    opened_at { Time.now }
  end
end
