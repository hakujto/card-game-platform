require 'rails_helper'

RSpec.describe "Api::Marketplace::TradeDisputes", type: :request do
  before(:each) do
    @aux_player = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @aux_card_set = CardSet.create!({ name: 'test', code: 'test', release_date: Date.today, rotation_date: nil, set_type: :core, total_cards: 1, is_rotated: false })
    @aux_card = Card.create!({ name: 'test', card_type: :spell, rarity: :common, mana_cost: 1, mana_colors: :white, attack: 1, defense: 1, loyalty: nil, description: 'test', legal_formats: :standard, is_banned: false, is_restricted: false, power_level: 1, set_id: @aux_card_set.id })
    @aux_trade_listing = TradeListing.create!({ listing_type: :trade_offer, asking_price: '0.00', auction_start_price: '0.00', auction_end_time: Time.now, foil: true, condition: :mint, quantity: 1, status: :active, created_at: Time.now, seller_id: @aux_player.id, card_id: @aux_card.id })
    @dep_transaction = TradeTransaction.create!({ final_price: '0.01', platform_fee: '0.01', status: :pending, completed_at: Time.now, listing_id: @aux_trade_listing.id, buyer_id: @aux_player.id, seller_id: @aux_player.id })
  end

  let(:valid_attributes) do
    {
      reason: :item_not_received,
      description: 'test',
      status: :resolved,
      opened_at: Time.now,
      transaction_id: @dep_transaction.id,
      opened_by_id: @aux_player.id
    }
  end

  describe "GET /api/trade_disputes" do
    it "returns 200" do
      get "/api/trade_disputes"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/trade_disputes" do
    context "with valid params" do
      it "returns 201" do
              fresh_sub_listing = TradeListing.create!({ listing_type: :trade_offer, foil: true, condition: :mint, quantity: 1, status: :active, created_at: Time.now, seller_id: @aux_player.id, card_id: @aux_card.id })
      fresh_transaction = TradeTransaction.create!({ final_price: '0.01', platform_fee: '0.01', status: :pending, listing_id: fresh_sub_listing.id, buyer_id: @aux_player.id, seller_id: @aux_player.id })
      post "/api/trade_disputes", params: { trade_dispute: {
      reason: :item_not_received,
      description: 'test',
      status: :resolved,
      opened_at: Time.now,
      transaction_id: fresh_transaction.id,
      opened_by_id: @aux_player.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/trade_disputes/:id" do
    let!(:tradeDispute) { TradeDispute.create!(valid_attributes) }

    it "returns 200" do
      get "/api/trade_disputes/#{tradeDispute.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/trade_disputes/:id" do
    let!(:tradeDispute) { TradeDispute.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/trade_disputes/#{tradeDispute.id}",
            params: { trade_dispute: { reason: :item_not_received } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/trade_disputes/:id" do
    let!(:tradeDispute) { TradeDispute.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/trade_disputes/#{tradeDispute.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/trade_disputes (rule: resolved_at_requires_terminal_status)" do
    it "create fails when resolved at requires terminal status violated" do
      # resolved_at_requires_terminal_status
      post "/api/trade_disputes", params: { trade_dispute: {
        reason: :item_not_received,
        description: 'test',
        opened_at: Time.now,
        transaction_id: 1,
        opened_by_id: 1,
        resolved_at: Time.now,
        status: :open,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
