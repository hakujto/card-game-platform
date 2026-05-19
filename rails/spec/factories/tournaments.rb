FactoryBot.define do
  factory :tournament do
    name { 'test' }
    status { :draft }
    format { :standard }
    tournament_type { :swiss }
    max_players { 1 }
  end
end
