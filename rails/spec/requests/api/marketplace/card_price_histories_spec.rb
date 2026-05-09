require 'rails_helper'

RSpec.describe "Api::Marketplace::CardPriceHistories", type: :request do
  let(:valid_attributes) do
    {
        price_date: Date.today,
        avg_price: '0.00',
        min_price: '0.00',
        max_price: '0.00',
        volume: 1,
        foil: true
    }
  end

  describe "GET /api/card_price_histories" do
    it "returns 200" do
      get "/api/card_price_histories"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/card_price_histories" do
    context "with valid params" do
      it "returns 201" do
        post "/api/card_price_histories", params: { card_price_history: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/card_price_histories/:id" do
    let!(:cardPriceHistory) { CardPriceHistory.create!(valid_attributes) }

    it "returns 200" do
      get "/api/card_price_histories/#{cardPriceHistory.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/card_price_histories/:id" do
    let!(:cardPriceHistory) { CardPriceHistory.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/card_price_histories/#{cardPriceHistory.id}",
            params: { card_price_history: { price_date: Date.today } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/card_price_histories/:id" do
    let!(:cardPriceHistory) { CardPriceHistory.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/card_price_histories/#{cardPriceHistory.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
