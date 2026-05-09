require 'rails_helper'

RSpec.describe "Api::Tournaments::Matches", type: :request do
  let(:valid_attributes) do
    {
        player1_wins: 1,
        player2_wins: 1
    }
  end

  describe "GET /api/matches" do
    it "returns 200" do
      get "/api/matches"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/matches" do
    context "with valid params" do
      it "returns 201" do
        post "/api/matches", params: { match: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/matches/:id" do
    let!(:match) { Match.create!(valid_attributes) }

    it "returns 200" do
      get "/api/matches/#{match.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/matches/:id" do
    let!(:match) { Match.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/matches/#{match.id}",
            params: { match: { table_number: 1 } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/matches/:id" do
    let!(:match) { Match.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/matches/#{match.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
