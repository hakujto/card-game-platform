require 'rails_helper'

RSpec.describe "Api::Players::PlayerSeasonStatses", type: :request do
  before(:each) do
    @dep_player = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
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

  describe "POST /api/player_season_statses" do
    context "with valid params" do
      it "returns 201" do
        post "/api/player_season_statses", params: { player_season_stats: {
      wins: 1,
      losses: 1,
      draws: 1,
      tournament_wins: 1,
      season_points: 1,
      player_id: @dep_player.id,
      season_id: @dep_season.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/player_season_statses/:id" do
    let!(:playerSeasonStats) { PlayerSeasonStats.create!(valid_attributes) }

    it "returns 200" do
      get "/api/player_season_statses/#{playerSeasonStats.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/player_season_statses/:id" do
    let!(:playerSeasonStats) { PlayerSeasonStats.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/player_season_statses/#{playerSeasonStats.id}",
            params: { player_season_stats: { wins: 1 } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/player_season_statses/:id" do
    let!(:playerSeasonStats) { PlayerSeasonStats.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/player_season_statses/#{playerSeasonStats.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/player_season_statses (rule: wins_not_negative)" do
    it "create fails when wins not negative violated" do
      # Season wins must not be negative
      post "/api/player_season_statses", params: { player_season_stats: {
        player_id: 1,
        season_id: 1,
        wins: -1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/player_season_statses (rule: losses_not_negative)" do
    it "create fails when losses not negative violated" do
      # Season losses must not be negative
      post "/api/player_season_statses", params: { player_season_stats: {
        player_id: 1,
        season_id: 1,
        losses: -1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/player_season_statses (rule: tournament_wins_not_negative)" do
    it "create fails when tournament wins not negative violated" do
      # Season tournament wins must not be negative
      post "/api/player_season_statses", params: { player_season_stats: {
        player_id: 1,
        season_id: 1,
        tournament_wins: -1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/player_season_statses (rule: season_points_not_negative)" do
    it "create fails when season points not negative violated" do
      # Season points must not be negative
      post "/api/player_season_statses", params: { player_season_stats: {
        player_id: 1,
        season_id: 1,
        season_points: -1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
