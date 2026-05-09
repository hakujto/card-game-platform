FactoryBot.define do
  factory :trade_transaction do
    final_price { '0.00' }
    platform_fee { '0.00' }
    status { :pending }
  end
end
