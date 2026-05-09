FactoryBot.define do
  factory :achievement do
    name { 'test' }
    description { 'test' }
    points { 1 }
    rarity { :common }
    is_hidden { true }
  end
end
