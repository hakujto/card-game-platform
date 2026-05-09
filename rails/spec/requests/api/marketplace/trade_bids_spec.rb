require 'rails_helper'

RSpec.describe "Api::Marketplace::TradeBids", type: :request do
  let(:valid_attributes) do
    {
        amount: '0.00',
        placed_at: Time.now,
        is_winning: true
    }
  end

  describe "GET /api/trade_bids" do
    it "returns 200" do
      get "/api/trade_bids"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/trade_bids" do
    context "with valid params" do
      it "returns 201" do
        post "/api/trade_bids", params: { trade_bid: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/trade_bids/:id" do
    let!(:tradeBid) { TradeBid.create!(valid_attributes) }

    it "returns 200" do
      get "/api/trade_bids/#{tradeBid.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/trade_bids/:id" do
    let!(:tradeBid) { TradeBid.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/trade_bids/#{tradeBid.id}",
            params: { trade_bid: { amount: '0.00' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/trade_bids/:id" do
    let!(:tradeBid) { TradeBid.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/trade_bids/#{tradeBid.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
