require 'rails_helper'

RSpec.describe "Api::Players::PlayerSeasonStatses", type: :request do
  let(:valid_attributes) do
    {
        wins: 1,
        losses: 1,
        draws: 1,
        tournament_wins: 1,
        season_points: 1
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
        post "/api/player_season_statses", params: { player_season_stats: valid_attributes }, as: :json
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
end
