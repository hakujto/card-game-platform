require 'rails_helper'

RSpec.describe "Api::Marketplace::Coupons", type: :request do
  let(:valid_attributes) do
    {
        code: 'test',
        discount_value: '0.00',
        min_order_value: '0.00',
        uses_count: 1,
        valid_from: Time.now,
        valid_until: Time.now,
        is_active: true
    }
  end

  describe "GET /api/coupons" do
    it "returns 200" do
      get "/api/coupons"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/coupons" do
    context "with valid params" do
      it "returns 201" do
        post "/api/coupons", params: { coupon: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/coupons/:id" do
    let!(:coupon) { Coupon.create!(valid_attributes) }

    it "returns 200" do
      get "/api/coupons/#{coupon.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/coupons/:id" do
    let!(:coupon) { Coupon.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/coupons/#{coupon.id}",
            params: { coupon: { code: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/coupons/:id" do
    let!(:coupon) { Coupon.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/coupons/#{coupon.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
