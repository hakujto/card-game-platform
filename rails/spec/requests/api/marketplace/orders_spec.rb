require 'rails_helper'

RSpec.describe "Api::Marketplace::Orders", type: :request do
  before(:each) do
    @dep_player = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
  end

  let(:valid_attributes) do
    {
      status: :pending,
      total: '0.00',
      discount_applied: '0.00',
      currency: 'xxx',
      created_at: Time.now,
      player_id: @dep_player.id
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
        post "/api/orders", params: { order: {
      status: :pending,
      total: '0.00',
      discount_applied: '0.00',
      currency: 'xxx',
      created_at: Time.now,
      player_id: @dep_player.id
        } }, as: :json
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
            params: { order: { total: '0.00' } },
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

  describe "POST /api/orders (rule: paid_requires_paid_at)" do
    it "create fails when paid requires paid at violated" do
      # Paid order must have paid_at set
      post "/api/orders", params: { order: {
        created_at: Time.now,
        player_id: 1,
        status: :paid,
        paid_at: nil,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/orders (rule: shipped_requires_tracking)" do
    it "create fails when shipped requires tracking violated" do
      # Shipped order must have a tracking number
      post "/api/orders", params: { order: {
        created_at: Time.now,
        player_id: 1,
        status: :shipped,
        tracking_number: nil,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/orders (rule: shipped_at_requires_shipped_status)" do
    it "create fails when shipped at requires shipped status violated" do
      # shipped_at_requires_shipped_status
      post "/api/orders", params: { order: {
        created_at: Time.now,
        player_id: 1,
        shipped_at: Time.now,
        status: :pending,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/orders (rule: total_not_negative)" do
    it "create fails when total not negative violated" do
      # Order total must not be negative
      post "/api/orders", params: { order: {
        created_at: Time.now,
        player_id: 1,
        paid_at: Time.now,
        tracking_number: 'test',
        shipped_at: Time.now,
        status: :shipped,
        total: -1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
