FactoryBot.define do
  factory :friendship do
    status { :pending }
    created_at { Time.now }
  end
end
