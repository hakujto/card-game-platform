FactoryBot.define do
  factory :player do
    display_name { 'test' }
    rank { :bronze }
    rating { 1 }
    peak_rating { 1 }
    is_verified { true }
  end
end
