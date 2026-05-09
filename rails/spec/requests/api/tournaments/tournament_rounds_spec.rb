require 'rails_helper'

RSpec.describe "Api::Tournaments::TournamentRounds", type: :request do
  let(:valid_attributes) do
    {
        round_number: 1,
        time_limit_minutes: 1
    }
  end

  describe "GET /api/tournament_rounds" do
    it "returns 200" do
      get "/api/tournament_rounds"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/tournament_rounds" do
    context "with valid params" do
      it "returns 201" do
        post "/api/tournament_rounds", params: { tournament_round: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/tournament_rounds/:id" do
    let!(:tournamentRound) { TournamentRound.create!(valid_attributes) }

    it "returns 200" do
      get "/api/tournament_rounds/#{tournamentRound.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/tournament_rounds/:id" do
    let!(:tournamentRound) { TournamentRound.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/tournament_rounds/#{tournamentRound.id}",
            params: { tournament_round: { round_number: 1 } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/tournament_rounds/:id" do
    let!(:tournamentRound) { TournamentRound.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/tournament_rounds/#{tournamentRound.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
