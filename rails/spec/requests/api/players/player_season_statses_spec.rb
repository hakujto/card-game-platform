require 'rails_helper'

RSpec.describe "Api::Players::PlayerSeasonStatses", type: :request do
  before(:each) do
    @dep_player = Player.create!({ public_id: SecureRandom.uuid, display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @dep_season = Season.create!({ name: 'test', start_date: Date.today, end_date: Date.today + 1, format: :standard, is_active: true })
  end

  let(:valid_attributes) do
    {
      wins: 1,
      losses: 1,
      draws: 1,
      tournament_wins: 1,
      season_points: 1,
      player_id: @dep_player.id,
      season_id: @dep_season.id
    }
  end

  describe "GET /api/player_season_statses" do
    it "returns 200" do
      get "/api/player_season_statses"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /api/player_season_statses/:id" do
    let!(:playerSeasonStats) { PlayerSeasonStats.create!(valid_attributes) }

    it "returns 200" do
      get "/api/player_season_statses/#{playerSeasonStats.id}"
      expect(response).to have_http_status(:ok)
    end
  end

end
