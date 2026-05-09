FactoryBot.define do
  factory :match do
    status { :pending }
    player1_wins { 1 }
    player2_wins { 1 }
  end
end
