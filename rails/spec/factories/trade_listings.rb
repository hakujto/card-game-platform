FactoryBot.define do
  factory :trade_listing do
    status { :active }
    listing_type { :fixed_price }
    foil { true }
    condition { :mint }
    quantity { 1 }
  end
end
