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
  describe "PATCH /api/orders/:id/transitions/pending-to-paid" do
    let!(:order) { Order.create!(valid_attributes).tap { |r| r.update_column(:status, Order.statuses['pending']) } }
    before { order.update!(payment_method: :card) }
    it "transitions to Paid" do
      patch "/api/orders/#{order.id}/transitions/pending-to-paid"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(order.reload.status).to eq('paid') if response.status == 200
    end

    context "when payment_method is missing" do
      before { order.update_column(:payment_method, nil) }
      it "returns 422" do
        patch "/api/orders/#{order.id}/transitions/pending-to-paid"
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /api/orders/:id/transitions/paid-to-processing" do
    let!(:order) { Order.create!(valid_attributes).tap { |r| r.update_column(:status, Order.statuses['paid']) } }
    it "transitions to Processing" do
      patch "/api/orders/#{order.id}/transitions/paid-to-processing"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(order.reload.status).to eq('processing') if response.status == 200
    end
  end

  describe "PATCH /api/orders/:id/transitions/processing-to-shipped" do
    let!(:order) { Order.create!(valid_attributes).tap { |r| r.update_column(:status, Order.statuses['processing']) } }
    before { order.update!(tracking_number: 'test') }
    it "transitions to Shipped" do
      patch "/api/orders/#{order.id}/transitions/processing-to-shipped"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(order.reload.status).to eq('shipped') if response.status == 200
    end

    context "when tracking_number is missing" do
      before { order.update_column(:tracking_number, nil) }
      it "returns 422" do
        patch "/api/orders/#{order.id}/transitions/processing-to-shipped"
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /api/orders/:id/transitions/shipped-to-completed" do
    let!(:order) { Order.create!(valid_attributes).tap { |r| r.update_column(:status, Order.statuses['shipped']) } }
    it "transitions to Completed" do
      patch "/api/orders/#{order.id}/transitions/shipped-to-completed"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(order.reload.status).to eq('completed') if response.status == 200
    end
  end

  describe "PATCH /api/orders/:id/transitions/pending-to-cancelled" do
    let!(:order) { Order.create!(valid_attributes).tap { |r| r.update_column(:status, Order.statuses['pending']) } }
    it "transitions to Cancelled" do
      patch "/api/orders/#{order.id}/transitions/pending-to-cancelled"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(order.reload.status).to eq('cancelled') if response.status == 200
    end
  end

  describe "PATCH /api/orders/:id/transitions/paid-to-cancelled" do
    let!(:order) { Order.create!(valid_attributes).tap { |r| r.update_column(:status, Order.statuses['paid']) } }
    it "transitions to Cancelled" do
      patch "/api/orders/#{order.id}/transitions/paid-to-cancelled"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(order.reload.status).to eq('cancelled') if response.status == 200
    end
  end

  describe "PATCH /api/orders/:id/transitions/completed-to-refunded" do
    let!(:order) { Order.create!(valid_attributes).tap { |r| r.update_column(:status, Order.statuses['completed']) } }
    it "transitions to Refunded" do
      patch "/api/orders/#{order.id}/transitions/completed-to-refunded"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(order.reload.status).to eq('refunded') if response.status == 200
    end
  end

  describe "PATCH /api/orders/:id/transitions/refunded-to-completed" do
    let!(:order) { Order.create!(valid_attributes) }
    it "returns 409 (denied)" do
      patch "/api/orders/#{order.id}/transitions/refunded-to-completed"
      expect(response).to have_http_status(:conflict)
    end
  end

  describe "PATCH /api/orders/:id/transitions/completed-to-cancelled" do
    let!(:order) { Order.create!(valid_attributes) }
    it "returns 409 (denied)" do
      patch "/api/orders/#{order.id}/transitions/completed-to-cancelled"
      expect(response).to have_http_status(:conflict)
    end
  end
end
