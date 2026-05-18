FactoryBot.define do
  factory :trade_listing do
    listing_type { :fixed_price }
    foil { true }
    condition { :mint }
    quantity { 1 }
    status { :active }
  end
end
