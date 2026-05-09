FactoryBot.define do
  factory :tournament_prize do
    placement_from { 1 }
    placement_to { 1 }
    prize_type { :currency }
    amount { '0.00' }
    season_points { 1 }
  end
end
