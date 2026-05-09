FactoryBot.define do
  factory :season do
    name { 'test' }
    start_date { Date.today }
    end_date { Date.today }
    format { :standard }
    is_active { true }
  end
end
