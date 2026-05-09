FactoryBot.define do
  factory :draft_session do
    status { :waiting_for_players }
    draft_type { :booster }
    seats { 1 }
    created_at { Time.now }
  end
end
