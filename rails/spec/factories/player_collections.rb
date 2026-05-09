FactoryBot.define do
  factory :player_collection do
    quantity { 1 }
    foil { true }
    condition { :mint }
    acquired_at { Time.now }
    acquired_via { :purchase }
  end
end
