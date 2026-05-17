require 'rails_helper'

RSpec.describe "Api::Marketplace::Coupons", type: :request do
  let(:valid_attributes) do
    {
      code: 'test',
      discount_type: :fixed,
      discount_value: '1.00',
      min_order_value: '0.00',
      uses_count: 1,
      valid_from: Time.now,
      valid_until: Time.now + 1,
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
        post "/api/coupons", params: { coupon: {
      code: 'test',
      discount_type: :fixed,
      discount_value: '1.00',
      min_order_value: '0.00',
      uses_count: 1,
      valid_from: Time.now,
      valid_until: Time.now + 1,
      is_active: true
        } }, as: :json
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

  describe "POST /api/coupons (rule: valid_until_after_valid_from)" do
    it "create fails when valid until after valid from violated" do
      # Coupon expiry must be after its start date
      post "/api/coupons", params: { coupon: {
        code: 'test',
        valid_from: Time.now,
        discount_value: 1,
        max_uses: 1,
        valid_until: Time.now - 1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/coupons (rule: discount_value_positive)" do
    it "create fails when discount value positive violated" do
      # Discount value must be greater than zero
      post "/api/coupons", params: { coupon: {
        code: 'test',
        valid_from: Time.now,
        valid_until: Time.now,
        max_uses: 1,
        discount_value: 0,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/coupons (rule: percent_discount_range)" do
    it "create fails when percent discount range violated" do
      # Percent discount must be between 1 and 100
      post "/api/coupons", params: { coupon: {
        code: 'test',
        valid_from: Time.now,
        valid_until: Time.now,
        discount_type: :percent,
        discount_value: 101,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/coupons (rule: uses_not_exceed_max)" do
    it "create fails when uses not exceed max violated" do
      # Coupon uses count cannot exceed max_uses
      post "/api/coupons", params: { coupon: {
        code: 'test',
        discount_value: '0.00',
        valid_from: Time.now,
        valid_until: Time.now,
        max_uses: 1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
