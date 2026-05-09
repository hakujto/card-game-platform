require 'rails_helper'

RSpec.describe "Api::Tournaments::Games", type: :request do
  let(:valid_attributes) do
    {
        game_number: 1
    }
  end

  describe "GET /api/games" do
    it "returns 200" do
      get "/api/games"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/games" do
    context "with valid params" do
      it "returns 201" do
        post "/api/games", params: { game: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/games/:id" do
    let!(:game) { Game.create!(valid_attributes) }

    it "returns 200" do
      get "/api/games/#{game.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/games/:id" do
    let!(:game) { Game.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/games/#{game.id}",
            params: { game: { game_number: 1 } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/games/:id" do
    let!(:game) { Game.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/games/#{game.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
