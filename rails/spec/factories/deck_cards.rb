FactoryBot.define do
  factory :deck_card do
    quantity { 1 }
    is_commander { true }
  end
end
