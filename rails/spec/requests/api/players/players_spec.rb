require 'rails_helper'

RSpec.describe "Api::Players::Players", type: :request do
  let(:valid_attributes) do
    {
      display_name: 'test',
      rank: :bronze,
      rating: 1,
      peak_rating: 1,
      is_verified: true,
      created_at: Time.now
    }
  end

  describe "GET /api/players" do
    it "returns 200" do
      get "/api/players"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/players" do
    context "with valid params" do
      it "returns 201" do
        post "/api/players", params: { player: {
      display_name: 'test',
      rank: :bronze,
      rating: 1,
      peak_rating: 1,
      is_verified: true,
      created_at: Time.now
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/players/:id" do
    let!(:player) { Player.create!(valid_attributes) }

    it "returns 200" do
      get "/api/players/#{player.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/players/:id" do
    let!(:player) { Player.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/players/#{player.id}",
            params: { player: { display_name: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/players/:id" do
    let!(:player) { Player.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/players/#{player.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/players (rule: rating_range)" do
    it "create fails when rating range violated" do
      # Rating must be between 0 and 9999
      post "/api/players", params: { player: {
        display_name: 'test',
        created_at: Time.now,
        rating: 10000,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
