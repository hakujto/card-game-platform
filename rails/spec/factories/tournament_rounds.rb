FactoryBot.define do
  factory :tournament_round do
    round_number { 1 }
    status { :pending }
    time_limit_minutes { 1 }
  end
end
