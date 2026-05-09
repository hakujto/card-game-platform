FactoryBot.define do
  factory :card do
    name { 'test' }
    card_type { :creature }
    rarity { :common }
    mana_cost { 1 }
    mana_colors { :white }
  end
end
