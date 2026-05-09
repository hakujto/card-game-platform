FactoryBot.define do
  factory :draft_pick do
    pick_number { 1 }
    pack_number { 1 }
    picked_at { Time.now }
  end
end
