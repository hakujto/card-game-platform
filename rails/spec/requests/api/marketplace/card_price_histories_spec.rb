require 'rails_helper'

RSpec.describe "Api::Marketplace::CardPriceHistories", type: :request do
  before(:each) do
    @aux_card_set = CardSet.create!({ name: 'test', code: 'test', release_date: Date.today, rotation_date: nil, set_type: :core, total_cards: 1, is_rotated: false })
    @dep_card = Card.create!({ name: 'test', card_type: :spell, rarity: :common, mana_cost: 0, mana_colors: :white, attack: 1, defense: 1, loyalty: nil, description: 'test', legal_formats: :standard, is_banned: false, is_restricted: false, power_level: 1, set_id: @aux_card_set.id })
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

  describe "GET /api/card_price_histories/:id" do
    let!(:cardPriceHistory) { CardPriceHistory.create!(valid_attributes) }

    it "returns 200" do
      get "/api/card_price_histories/#{cardPriceHistory.id}"
      expect(response).to have_http_status(:ok)
    end
  end

end
