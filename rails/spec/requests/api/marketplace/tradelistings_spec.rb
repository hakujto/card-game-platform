require 'rails_helper'

RSpec.describe "Api::Marketplace::Tradelistings", type: :request do
  let(:valid_attributes) do
    {
        foil: true,
        quantity: 1,
        created_at: Time.now
    }
  end

  describe "GET /api/tradelistings" do
    it "returns 200" do
      get "/api/tradelistings"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/tradelistings" do
    context "with valid params" do
      it "returns 201" do
        post "/api/tradelistings", params: { tradelisting: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/tradelistings/:id" do
    let!(:tradelisting) { Tradelisting.create!(valid_attributes) }

    it "returns 200" do
      get "/api/tradelistings/#{tradelisting.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/tradelistings/:id" do
    let!(:tradelisting) { Tradelisting.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/tradelistings/#{tradelisting.id}",
            params: { tradelisting: { listing_type: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/tradelistings/:id" do
    let!(:tradelisting) { Tradelisting.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/tradelistings/#{tradelisting.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
