FactoryBot.define do
  factory :deck do
    name { 'test' }
    format { :standard }
    is_public { true }
    is_tournament_legal { true }
    wins { 1 }
  end
end
