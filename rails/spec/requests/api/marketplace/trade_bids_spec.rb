require 'rails_helper'

RSpec.describe "Api::Marketplace::TradeBids", type: :request do
  before(:each) do
    @aux_player = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @aux_card_set = CardSet.create!({ name: 'test', code: 'test', release_date: Date.today, rotation_date: nil, set_type: :core, total_cards: 1, is_rotated: false })
    @aux_card = Card.create!({ name: 'test', card_type: :spell, rarity: :common, mana_cost: 1, mana_colors: :white, attack: 1, defense: 1, loyalty: nil, description: 'test', legal_formats: :standard, is_banned: false, is_restricted: false, power_level: 1, set_id: @aux_card_set.id })
    @dep_listing = TradeListing.create!({ listing_type: :trade_offer, asking_price: '0.00', auction_start_price: '0.00', auction_end_time: Time.now, foil: true, condition: :mint, quantity: 1, status: :active, created_at: Time.now, seller_id: @aux_player.id, card_id: @aux_card.id })
  end

  let(:valid_attributes) do
    {
      amount: '0.01',
      placed_at: Time.now,
      is_winning: true,
      listing_id: @dep_listing.id,
      bidder_id: @aux_player.id
    }
  end

  describe "GET /api/trade_bids" do
    it "returns 200" do
      get "/api/trade_bids"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/trade_bids" do
    context "with valid params" do
      it "returns 201" do
        post "/api/trade_bids", params: { trade_bid: {
      amount: '0.01',
      placed_at: Time.now,
      is_winning: true,
      listing_id: @dep_listing.id,
      bidder_id: @aux_player.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/trade_bids/:id" do
    let!(:tradeBid) { TradeBid.create!(valid_attributes) }

    it "returns 200" do
      get "/api/trade_bids/#{tradeBid.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/trade_bids/:id" do
    let!(:tradeBid) { TradeBid.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/trade_bids/#{tradeBid.id}",
            params: { trade_bid: { placed_at: Time.now } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/trade_bids/:id" do
    let!(:tradeBid) { TradeBid.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/trade_bids/#{tradeBid.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/trade_bids (rule: amount_positive)" do
    it "create fails when amount positive violated" do
      # Bid amount must be greater than zero
      post "/api/trade_bids", params: { trade_bid: {
        placed_at: Time.now,
        listing_id: 1,
        bidder_id: 1,
        amount: 0,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
