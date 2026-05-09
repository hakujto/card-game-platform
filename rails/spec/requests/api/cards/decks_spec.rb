require 'rails_helper'

RSpec.describe "Api::Cards::Decks", type: :request do
  let(:valid_attributes) do
    {
        name: 'test',
        is_public: true,
        is_tournament_legal: true,
        wins: 1,
        losses: 1,
        created_at: Time.now,
        updated_at: Time.now
    }
  end

  describe "GET /api/decks" do
    it "returns 200" do
      get "/api/decks"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/decks" do
    context "with valid params" do
      it "returns 201" do
        post "/api/decks", params: { deck: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/decks/:id" do
    let!(:deck) { Deck.create!(valid_attributes) }

    it "returns 200" do
      get "/api/decks/#{deck.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/decks/:id" do
    let!(:deck) { Deck.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/decks/#{deck.id}",
            params: { deck: { name: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/decks/:id" do
    let!(:deck) { Deck.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/decks/#{deck.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
