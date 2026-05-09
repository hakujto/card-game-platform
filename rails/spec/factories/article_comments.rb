FactoryBot.define do
  factory :article_comment do
    body { 'test' }
    is_hidden { true }
    created_at { Time.now }
  end
end
