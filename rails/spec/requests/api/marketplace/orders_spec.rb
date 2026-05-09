require 'rails_helper'

RSpec.describe "Api::Marketplace::Orders", type: :request do
  let(:valid_attributes) do
    {
        total: '0.00',
        discount_applied: '0.00',
        currency: 'test',
        created_at: Time.now
    }
  end

  describe "GET /api/orders" do
    it "returns 200" do
      get "/api/orders"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/orders" do
    context "with valid params" do
      it "returns 201" do
        post "/api/orders", params: { order: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/orders/:id" do
    let!(:order) { Order.create!(valid_attributes) }

    it "returns 200" do
      get "/api/orders/#{order.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/orders/:id" do
    let!(:order) { Order.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/orders/#{order.id}",
            params: { order: { status: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/orders/:id" do
    let!(:order) { Order.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/orders/#{order.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
