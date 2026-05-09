require 'rails_helper'

RSpec.describe "Api::Cards::DeckSideboardCards", type: :request do
  let(:valid_attributes) do
    {
        quantity: 1
    }
  end

  describe "GET /api/deck_sideboard_cards" do
    it "returns 200" do
      get "/api/deck_sideboard_cards"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/deck_sideboard_cards" do
    context "with valid params" do
      it "returns 201" do
        post "/api/deck_sideboard_cards", params: { deck_sideboard_card: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/deck_sideboard_cards/:id" do
    let!(:deckSideboardCard) { DeckSideboardCard.create!(valid_attributes) }

    it "returns 200" do
      get "/api/deck_sideboard_cards/#{deckSideboardCard.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/deck_sideboard_cards/:id" do
    let!(:deckSideboardCard) { DeckSideboardCard.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/deck_sideboard_cards/#{deckSideboardCard.id}",
            params: { deck_sideboard_card: { quantity: 1 } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/deck_sideboard_cards/:id" do
    let!(:deckSideboardCard) { DeckSideboardCard.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/deck_sideboard_cards/#{deckSideboardCard.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
