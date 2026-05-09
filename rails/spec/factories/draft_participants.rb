FactoryBot.define do
  factory :draft_participant do
    seat_number { 1 }
    joined_at { Time.now }
  end
end
