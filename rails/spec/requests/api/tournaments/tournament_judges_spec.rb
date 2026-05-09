require 'rails_helper'

RSpec.describe "Api::Tournaments::TournamentJudges", type: :request do
  let(:valid_attributes) do
    {
        # add required fields here
    }
  end

  describe "GET /api/tournament_judges" do
    it "returns 200" do
      get "/api/tournament_judges"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/tournament_judges" do
    context "with valid params" do
      it "returns 201" do
        post "/api/tournament_judges", params: { tournament_judge: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/tournament_judges/:id" do
    let!(:tournamentJudge) { TournamentJudge.create!(valid_attributes) }

    it "returns 200" do
      get "/api/tournament_judges/#{tournamentJudge.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/tournament_judges/:id" do
    let!(:tournamentJudge) { TournamentJudge.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/tournament_judges/#{tournamentJudge.id}",
            params: { tournament_judge: { role: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/tournament_judges/:id" do
    let!(:tournamentJudge) { TournamentJudge.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/tournament_judges/#{tournamentJudge.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
