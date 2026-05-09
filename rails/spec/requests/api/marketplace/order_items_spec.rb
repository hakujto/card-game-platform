require 'rails_helper'

RSpec.describe "Api::Marketplace::OrderItems", type: :request do
  let(:valid_attributes) do
    {
        quantity: 1,
        price_at_purchase: '0.00',
        foil: true
    }
  end

  describe "GET /api/order_items" do
    it "returns 200" do
      get "/api/order_items"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/order_items" do
    context "with valid params" do
      it "returns 201" do
        post "/api/order_items", params: { order_item: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/order_items/:id" do
    let!(:orderItem) { OrderItem.create!(valid_attributes) }

    it "returns 200" do
      get "/api/order_items/#{orderItem.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/order_items/:id" do
    let!(:orderItem) { OrderItem.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/order_items/#{orderItem.id}",
            params: { order_item: { quantity: 1 } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/order_items/:id" do
    let!(:orderItem) { OrderItem.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/order_items/#{orderItem.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
