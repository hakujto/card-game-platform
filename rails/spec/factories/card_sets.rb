FactoryBot.define do
  factory :card_set do
    name { 'test' }
    code { 'test' }
    release_date { Date.today }
    set_type { :core }
    total_cards { 1 }
  end
end
