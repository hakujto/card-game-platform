require 'rails_helper'

RSpec.describe "Api::Marketplace::TradeDisputes", type: :request do
  let(:valid_attributes) do
    {
        description: 'test',
        opened_at: Time.now
    }
  end

  describe "GET /api/trade_disputes" do
    it "returns 200" do
      get "/api/trade_disputes"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/trade_disputes" do
    context "with valid params" do
      it "returns 201" do
        post "/api/trade_disputes", params: { trade_dispute: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/trade_disputes/:id" do
    let!(:tradeDispute) { TradeDispute.create!(valid_attributes) }

    it "returns 200" do
      get "/api/trade_disputes/#{tradeDispute.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/trade_disputes/:id" do
    let!(:tradeDispute) { TradeDispute.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/trade_disputes/#{tradeDispute.id}",
            params: { trade_dispute: { reason: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/trade_disputes/:id" do
    let!(:tradeDispute) { TradeDispute.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/trade_disputes/#{tradeDispute.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
