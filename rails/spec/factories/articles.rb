FactoryBot.define do
  factory :article do
    title { 'test' }
    slug { 'test' }
    body { 'test' }
    status { :draft }
    article_type { :guide }
  end
end
