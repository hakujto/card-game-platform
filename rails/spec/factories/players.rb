FactoryBot.define do
  factory :player do
    public_id { SecureRandom.uuid }
    display_name { 'test' }
    rank { :bronze }
    rating { 1 }
    peak_rating { 1 }
  end
end
