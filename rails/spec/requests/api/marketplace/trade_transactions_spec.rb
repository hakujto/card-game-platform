require 'rails_helper'

RSpec.describe "Api::Marketplace::TradeTransactions", type: :request do
  before(:each) do
    @aux_player = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @aux_card_set = CardSet.create!({ name: 'test', code: 'test', release_date: Date.today, set_type: :core, total_cards: 1 })
    @aux_card = Card.create!({ name: 'test', card_type: :spell, rarity: :common, mana_cost: 1, mana_colors: :white, description: 'test', legal_formats: :standard, is_banned: false, is_restricted: false, power_level: 1, set_id: @aux_card_set.id })
    @dep_listing = Tradelisting.create!({ listing_type: :trade_offer, foil: true, condition: :mint, quantity: 1, status: :active, created_at: Time.now, seller_id: @aux_player.id, card_id: @aux_card.id })
  end

  let(:valid_attributes) do
    {
      final_price: '0.00',
      platform_fee: '0.00',
      status: :pending,
      listing_id: @dep_listing.id,
      buyer_id: @aux_player.id,
      seller_id: @aux_player.id
    }
  end

  describe "GET /api/trade_transactions" do
    it "returns 200" do
      get "/api/trade_transactions"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/trade_transactions" do
    context "with valid params" do
      it "returns 201" do
              fresh_listing = Tradelisting.create!({ listing_type: :trade_offer, foil: true, condition: :mint, quantity: 1, status: :active, created_at: Time.now, seller_id: @aux_player.id, card_id: @aux_card.id })
      post "/api/trade_transactions", params: { trade_transaction: {
      final_price: '0.00',
      platform_fee: '0.00',
      status: :pending,
      listing_id: fresh_listing.id,
      buyer_id: @aux_player.id,
      seller_id: @aux_player.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/trade_transactions/:id" do
    let!(:tradeTransaction) { TradeTransaction.create!(valid_attributes) }

    it "returns 200" do
      get "/api/trade_transactions/#{tradeTransaction.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/trade_transactions/:id" do
    let!(:tradeTransaction) { TradeTransaction.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/trade_transactions/#{tradeTransaction.id}",
            params: { trade_transaction: { final_price: '0.00' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/trade_transactions/:id" do
    let!(:tradeTransaction) { TradeTransaction.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/trade_transactions/#{tradeTransaction.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/trade_transactions (rule: fee_not_negative)" do
    it "create fails when fee not negative violated" do
      # Platform fee must not be negative
      post "/api/trade_transactions", params: { trade_transaction: {
        final_price: '0.00',
        listing_id: 1,
        buyer_id: 1,
        seller_id: 1,
        completed_at: Time.now,
        platform_fee: -1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/trade_transactions (rule: completed_requires_completed_at)" do
    it "create fails when completed requires completed at violated" do
      # Completed transaction must have a completed_at timestamp
      post "/api/trade_transactions", params: { trade_transaction: {
        final_price: '0.00',
        platform_fee: '0.00',
        listing_id: 1,
        buyer_id: 1,
        seller_id: 1,
        status: :completed,
        completed_at: nil,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
