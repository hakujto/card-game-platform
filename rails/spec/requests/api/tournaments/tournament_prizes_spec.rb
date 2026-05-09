require 'rails_helper'

RSpec.describe "Api::Tournaments::TournamentPrizes", type: :request do
  let(:valid_attributes) do
    {
        placement_from: 1,
        placement_to: 1,
        amount: '0.00',
        season_points: 1
    }
  end

  describe "GET /api/tournament_prizes" do
    it "returns 200" do
      get "/api/tournament_prizes"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/tournament_prizes" do
    context "with valid params" do
      it "returns 201" do
        post "/api/tournament_prizes", params: { tournament_prize: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/tournament_prizes/:id" do
    let!(:tournamentPrize) { TournamentPrize.create!(valid_attributes) }

    it "returns 200" do
      get "/api/tournament_prizes/#{tournamentPrize.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/tournament_prizes/:id" do
    let!(:tournamentPrize) { TournamentPrize.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/tournament_prizes/#{tournamentPrize.id}",
            params: { tournament_prize: { placement_from: 1 } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/tournament_prizes/:id" do
    let!(:tournamentPrize) { TournamentPrize.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/tournament_prizes/#{tournamentPrize.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
