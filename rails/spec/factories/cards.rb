FactoryBot.define do
  factory :card do
    public_id { SecureRandom.uuid }
    name { 'test' }
    card_type { :creature }
    rarity { :common }
    mana_cost { 1 }
  end
end
