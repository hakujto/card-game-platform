FactoryBot.define do
  factory :tournament do
    public_id { SecureRandom.uuid }
    name { 'test' }
    status { :draft }
    format { :standard }
    tournament_type { :swiss }
  end
end
