require 'rails_helper'

RSpec.describe "Api::Marketplace::Products", type: :request do
  let(:valid_attributes) do
    {
      name: 'test',
      product_type: :single_card,
      price: '0.01',
      stock: 1,
      active: true,
      discount_percent: 1,
      featured: true
    }
  end

  describe "GET /api/products" do
    it "returns 200" do
      get "/api/products"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/products" do
    context "with valid params" do
      it "returns 201" do
        post "/api/products", params: { product: {
      name: 'test',
      product_type: :single_card,
      price: '0.01',
      stock: 1,
      active: true,
      discount_percent: 1,
      featured: true
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/products/:id" do
    let!(:product) { Product.create!(valid_attributes) }

    it "returns 200" do
      get "/api/products/#{product.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/products/:id" do
    let!(:product) { Product.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/products/#{product.id}",
            params: { product: { name: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/products/:id" do
    let!(:product) { Product.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/products/#{product.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/products (rule: price_positive)" do
    it "create fails when price positive violated" do
      # Product price must be greater than zero
      post "/api/products", params: { product: {
        name: 'test',
        price: 0,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/products (rule: stock_not_negative)" do
    it "create fails when stock not negative violated" do
      # Product stock must not be negative
      post "/api/products", params: { product: {
        name: 'test',
        price: '0.00',
        stock: -1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/products (rule: discount_percent_range)" do
    it "create fails when discount percent range violated" do
      # Product discount percent must be between 0 and 100
      post "/api/products", params: { product: {
        name: 'test',
        price: '0.00',
        discount_percent: 101,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
