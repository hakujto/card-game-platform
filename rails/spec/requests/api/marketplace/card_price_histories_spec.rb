require 'rails_helper'

RSpec.describe "Api::Marketplace::CardPriceHistories", type: :request do
  before(:each) do
    @aux_card_set = CardSet.create!({ name: 'test', code: 'test', release_date: Date.today, rotation_date: nil, set_type: :core, total_cards: 1, is_rotated: false })
    @dep_card = Card.create!({ name: 'test', card_type: :spell, rarity: :common, mana_cost: 1, mana_colors: :white, attack: 1, defense: 1, loyalty: nil, description: 'test', legal_formats: :standard, is_banned: false, is_restricted: false, power_level: 1, set_id: @aux_card_set.id })
  end

  let(:valid_attributes) do
    {
      price_date: Date.today,
      avg_price: '0.00',
      min_price: '0.00',
      max_price: '0.00',
      volume: 1,
      foil: true,
      card_id: @dep_card.id
    }
  end

  describe "GET /api/card_price_histories" do
    it "returns 200" do
      get "/api/card_price_histories"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/card_price_histories" do
    context "with valid params" do
      it "returns 201" do
        post "/api/card_price_histories", params: { card_price_history: {
      price_date: Date.today,
      avg_price: '0.00',
      min_price: '0.00',
      max_price: '0.00',
      volume: 1,
      foil: true,
      card_id: @dep_card.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/card_price_histories/:id" do
    let!(:cardPriceHistory) { CardPriceHistory.create!(valid_attributes) }

    it "returns 200" do
      get "/api/card_price_histories/#{cardPriceHistory.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/card_price_histories/:id" do
    let!(:cardPriceHistory) { CardPriceHistory.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/card_price_histories/#{cardPriceHistory.id}",
            params: { card_price_history: { price_date: Date.today } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/card_price_histories/:id" do
    let!(:cardPriceHistory) { CardPriceHistory.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/card_price_histories/#{cardPriceHistory.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/card_price_histories (rule: volume_not_negative)" do
    it "create fails when volume not negative violated" do
      # Price history volume must not be negative
      post "/api/card_price_histories", params: { card_price_history: {
        price_date: Date.today,
        avg_price: '0.00',
        min_price: '0.00',
        max_price: '0.00',
        card_id: 1,
        volume: -1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/card_price_histories (rule: prices_not_negative)" do
    it "create fails when prices not negative violated" do
      # Prices must not be negative
      post "/api/card_price_histories", params: { card_price_history: {
        price_date: Date.today,
        avg_price: '0.00',
        max_price: '0.00',
        volume: 1,
        card_id: 1,
        min_price: -1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
