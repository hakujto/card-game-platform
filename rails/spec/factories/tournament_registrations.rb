FactoryBot.define do
  factory :tournament_registration do
    status { :registered }
    points_earned { 1 }
    registered_at { Time.now }
  end
end
