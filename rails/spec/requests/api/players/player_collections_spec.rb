require 'rails_helper'

RSpec.describe "Api::Players::PlayerCollections", type: :request do
  let(:valid_attributes) do
    {
        quantity: 1,
        foil: true,
        acquired_at: Time.now
    }
  end

  describe "GET /api/player_collections" do
    it "returns 200" do
      get "/api/player_collections"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/player_collections" do
    context "with valid params" do
      it "returns 201" do
        post "/api/player_collections", params: { player_collection: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/player_collections/:id" do
    let!(:playerCollection) { PlayerCollection.create!(valid_attributes) }

    it "returns 200" do
      get "/api/player_collections/#{playerCollection.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/player_collections/:id" do
    let!(:playerCollection) { PlayerCollection.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/player_collections/#{playerCollection.id}",
            params: { player_collection: { quantity: 1 } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/player_collections/:id" do
    let!(:playerCollection) { PlayerCollection.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/player_collections/#{playerCollection.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
