FactoryBot.define do
  factory :tournament do
    name { 'test' }
    format { :standard }
    tournament_type { :swiss }
    status { :draft }
    max_players { 1 }
  end
end
