FactoryBot.define do
  factory :player_achievement do
    earned_at { Time.now }
    progress { 1 }
    is_completed { true }
  end
end
