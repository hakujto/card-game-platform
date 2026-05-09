FactoryBot.define do
  factory :card_ruling do
    ruling_text { 'test' }
    published_at { Date.today }
    source { 'test' }
  end
end
