require 'rails_helper'

RSpec.describe "Api::Marketplace::TradeTransactions", type: :request do
  let(:valid_attributes) do
    {
        final_price: '0.00',
        platform_fee: '0.00'
    }
  end

  describe "GET /api/trade_transactions" do
    it "returns 200" do
      get "/api/trade_transactions"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/trade_transactions" do
    context "with valid params" do
      it "returns 201" do
        post "/api/trade_transactions", params: { trade_transaction: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/trade_transactions/:id" do
    let!(:tradeTransaction) { TradeTransaction.create!(valid_attributes) }

    it "returns 200" do
      get "/api/trade_transactions/#{tradeTransaction.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/trade_transactions/:id" do
    let!(:tradeTransaction) { TradeTransaction.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/trade_transactions/#{tradeTransaction.id}",
            params: { trade_transaction: { final_price: '0.00' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/trade_transactions/:id" do
    let!(:tradeTransaction) { TradeTransaction.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/trade_transactions/#{tradeTransaction.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
