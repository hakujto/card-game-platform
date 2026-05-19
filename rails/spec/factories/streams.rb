FactoryBot.define do
  factory :stream do
    title { 'test' }
    stream_url { 'https://example.com' }
    status { :scheduled }
    platform { :twitch }
    language { :e_n }
  end
end
