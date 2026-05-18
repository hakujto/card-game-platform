require 'rails_helper'

RSpec.describe "Api::Marketplace::OrderItems", type: :request do
  before(:each) do
    @aux_player = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @dep_order = Order.create!({ status: :pending, total: '0.00', discount_applied: '0.00', currency: 'xxx', tracking_number: 'test', created_at: Time.now, paid_at: Time.now, shipped_at: nil, player_id: @aux_player.id })
    @dep_product = Product.create!({ name: 'test', product_type: :single_card, price: '0.01', stock: 1, active: true, discount_percent: 1, featured: true })
  end

  let(:valid_attributes) do
    {
      quantity: 1,
      price_at_purchase: '0.00',
      foil: true,
      order_id: @dep_order.id,
      product_id: @dep_product.id
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
        post "/api/order_items", params: { order_item: {
      quantity: 1,
      price_at_purchase: '0.00',
      foil: true,
      order_id: @dep_order.id,
      product_id: @dep_product.id
        } }, as: :json
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
            params: { order_item: { price_at_purchase: '0.00' } },
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

  describe "POST /api/order_items (rule: quantity_positive)" do
    it "create fails when quantity positive violated" do
      # Order item quantity must be greater than zero
      post "/api/order_items", params: { order_item: {
        price_at_purchase: '0.00',
        order_id: 1,
        product_id: 1,
        quantity: 0,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/order_items (rule: price_not_negative)" do
    it "create fails when price not negative violated" do
      # Price at purchase must not be negative
      post "/api/order_items", params: { order_item: {
        quantity: 1,
        order_id: 1,
        product_id: 1,
        price_at_purchase: -1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
