FactoryBot.define do
  factory :awarded_prize do
    final_placement { 1 }
    awarded_at { Time.now }
    claimed { true }
  end
end
