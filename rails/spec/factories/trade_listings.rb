FactoryBot.define do
  factory :trade_listing do
    public_id { SecureRandom.uuid }
    status { :active }
    listing_type { :fixed_price }
    foil { true }
    condition { :mint }
  end
end
