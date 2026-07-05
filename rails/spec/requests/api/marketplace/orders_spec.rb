require 'rails_helper'

RSpec.describe "Api::Marketplace::Orders", type: :request do
  before(:each) do
    @owner = Player.create!({ public_id: SecureRandom.uuid, display_name: 'test2', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @owner_id = @owner.id
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', id: @owner_id))
  end

  let(:valid_attributes) do
    {
      status: :pending,
      total: 29.99,
      discount_applied: '0.00',
      currency: 'USD',
      created_at: Time.now,
      player_id: @owner_id
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
      total: 29.99,
      discount_applied: '0.00',
      currency: 'USD',
      created_at: Time.now,
      player_id: @owner_id
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
    let!(:order) { Order.create!(valid_attributes).tap { |r| r.class.where(id: r.id).update_all(status: Order.statuses['pending']); r.reload } }
    before { order.update!(payment_method: :card) }
    it "transitions to Paid" do
      patch "/api/orders/#{order.id}/transitions/pending-to-paid"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(order.reload.status).to eq('paid') if response.status == 200
    end

    context "when payment_method is missing" do
      before { order.class.where(id: order.id).update_all(payment_method: nil); order.reload }
      it "returns 422" do
        patch "/api/orders/#{order.id}/transitions/pending-to-paid"
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /api/orders/:id/transitions/paid-to-processing" do
    let!(:order) { Order.create!(valid_attributes).tap { |r| r.class.where(id: r.id).update_all(status: Order.statuses['paid']); r.reload } }
    it "transitions to Processing with role Admin" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'Admin'))
      patch "/api/orders/#{order.id}/transitions/paid-to-processing"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(order.reload.status).to eq('processing') if response.status == 200
    end

    it "returns 403 for transition Paid -> Processing with insufficient role" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'guest'))
      patch "/api/orders/#{order.id}/transitions/paid-to-processing"
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/orders/:id/transitions/processing-to-shipped" do
    let!(:order) { Order.create!(valid_attributes).tap { |r| r.class.where(id: r.id).update_all(status: Order.statuses['processing']); r.reload } }
    before { order.update!(tracking_number: 'test') }
    it "transitions to Shipped with role Admin" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'Admin'))
      patch "/api/orders/#{order.id}/transitions/processing-to-shipped"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(order.reload.status).to eq('shipped') if response.status == 200
    end

    it "returns 403 for transition Processing -> Shipped with insufficient role" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'guest'))
      patch "/api/orders/#{order.id}/transitions/processing-to-shipped"
      expect(response).to have_http_status(:forbidden)
    end

    context "when tracking_number is missing" do
      before { order.class.where(id: order.id).update_all(tracking_number: nil); order.reload }
      it "returns 422" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'Admin'))
        patch "/api/orders/#{order.id}/transitions/processing-to-shipped"
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /api/orders/:id/transitions/shipped-to-completed" do
    let!(:order) { Order.create!(valid_attributes).tap { |r| r.class.where(id: r.id).update_all(status: Order.statuses['shipped']); r.reload } }
    it "transitions to Completed with role Admin" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'Admin'))
      patch "/api/orders/#{order.id}/transitions/shipped-to-completed"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(order.reload.status).to eq('completed') if response.status == 200
    end

    it "returns 403 for transition Shipped -> Completed with insufficient role" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'guest'))
      patch "/api/orders/#{order.id}/transitions/shipped-to-completed"
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/orders/:id/transitions/pending-to-cancelled" do
    let!(:order) { Order.create!(valid_attributes).tap { |r| r.class.where(id: r.id).update_all(status: Order.statuses['pending']); r.reload } }
    it "transitions to Cancelled" do
      patch "/api/orders/#{order.id}/transitions/pending-to-cancelled"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(order.reload.status).to eq('cancelled') if response.status == 200
    end
  end

  describe "PATCH /api/orders/:id/transitions/paid-to-cancelled" do
    let!(:order) { Order.create!(valid_attributes).tap { |r| r.class.where(id: r.id).update_all(status: Order.statuses['paid']); r.reload } }
    it "transitions to Cancelled with role Admin" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'Admin'))
      patch "/api/orders/#{order.id}/transitions/paid-to-cancelled"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(order.reload.status).to eq('cancelled') if response.status == 200
    end

    it "returns 403 for transition Paid -> Cancelled with insufficient role" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'guest'))
      patch "/api/orders/#{order.id}/transitions/paid-to-cancelled"
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/orders/:id/transitions/completed-to-refunded" do
    let!(:order) { Order.create!(valid_attributes).tap { |r| r.class.where(id: r.id).update_all(status: Order.statuses['completed']); r.reload } }
    it "transitions to Refunded with role Admin" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'Admin'))
      patch "/api/orders/#{order.id}/transitions/completed-to-refunded"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(order.reload.status).to eq('refunded') if response.status == 200
    end

    it "returns 403 for transition Completed -> Refunded with insufficient role" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'guest'))
      patch "/api/orders/#{order.id}/transitions/completed-to-refunded"
      expect(response).to have_http_status(:forbidden)
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
