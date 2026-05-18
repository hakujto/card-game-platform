require 'rails_helper'

RSpec.describe "Api::Marketplace::TradeListings", type: :request do
  before(:each) do
    @dep_seller = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @aux_card_set = CardSet.create!({ name: 'test', code: 'test', release_date: Date.today, rotation_date: nil, set_type: :core, total_cards: 1, is_rotated: false })
    @dep_card = Card.create!({ name: 'test', card_type: :spell, rarity: :common, mana_cost: 1, mana_colors: :white, attack: 1, defense: 1, loyalty: nil, description: 'test', legal_formats: :standard, is_banned: false, is_restricted: false, power_level: 1, set_id: @aux_card_set.id })
  end

  let(:valid_attributes) do
    {
      listing_type: :trade_offer,
      foil: true,
      condition: :mint,
      quantity: 1,
      status: :active,
      created_at: Time.now,
      seller_id: @dep_seller.id,
      card_id: @dep_card.id
    }
  end

  describe "GET /api/trade_listings" do
    it "returns 200" do
      get "/api/trade_listings"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/trade_listings" do
    context "with valid params" do
      it "returns 201" do
        post "/api/trade_listings", params: { trade_listing: {
      listing_type: :trade_offer,
      foil: true,
      condition: :mint,
      quantity: 1,
      status: :active,
      created_at: Time.now,
      seller_id: @dep_seller.id,
      card_id: @dep_card.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/trade_listings/:id" do
    let!(:tradeListing) { TradeListing.create!(valid_attributes) }

    it "returns 200" do
      get "/api/trade_listings/#{tradeListing.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/trade_listings/:id" do
    let!(:tradeListing) { TradeListing.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/trade_listings/#{tradeListing.id}",
            params: { trade_listing: { auction_current_bid: '0.00' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/trade_listings/:id" do
    let!(:tradeListing) { TradeListing.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/trade_listings/#{tradeListing.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/trade_listings (rule: fixed_price_requires_asking_price)" do
    it "create fails when fixed price requires asking price violated" do
      # Fixed price listing must have an asking price
      post "/api/trade_listings", params: { trade_listing: {
        created_at: Time.now,
        seller_id: 1,
        card_id: 1,
        listing_type: :fixed_price,
        asking_price: nil,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/trade_listings (rule: auction_requires_start_price_and_end_time)" do
    it "create fails when auction requires start price and end time violated" do
      # Auction listing must have a start price and end time
      post "/api/trade_listings", params: { trade_listing: {
        created_at: Time.now,
        seller_id: 1,
        card_id: 1,
        listing_type: :auction,
        auction_start_price: nil,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/trade_listings (rule: quantity_positive)" do
    it "create fails when quantity positive violated" do
      # Listing quantity must be between 1 and 9999
      post "/api/trade_listings", params: { trade_listing: {
        created_at: Time.now,
        seller_id: 1,
        card_id: 1,
        asking_price: '0.00',
        auction_start_price: '0.00',
        auction_end_time: Time.now,
        quantity: 10000,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
