FactoryBot.define do
  factory :stream do
    title { 'test' }
    stream_url { 'https://example.com' }
    platform { :twitch }
    status { :scheduled }
    viewer_count_peak { 1 }
  end
end
