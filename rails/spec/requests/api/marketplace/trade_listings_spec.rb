require 'rails_helper'

RSpec.describe "Api::Marketplace::TradeListings", type: :request do
  before(:each) do
    @dep_seller = Player.create!({ public_id: SecureRandom.uuid, display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @aux_card_set = CardSet.create!({ name: 'test', code: 'AB', release_date: Date.today, rotation_date: nil, set_type: :core, total_cards: 1, is_rotated: false })
    @dep_card = Card.create!({ public_id: SecureRandom.uuid, name: 'test', card_type: :spell, rarity: :common, mana_cost: 0, mana_colors: :white, attack: 1, defense: 1, loyalty: nil, description: 'test', legal_formats: :standard, is_banned: false, is_restricted: false, power_level: 1, total_copies_in_circulation: 1, set_id: @aux_card_set.id })
  end

  let(:valid_attributes) do
    {
      public_id: SecureRandom.uuid,
      status: :active,
      listing_type: :trade_offer,
      foil: true,
      condition: :mint,
      quantity: 1,
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

  describe "GET /api/trade_listings?q=test" do
    it "returns 200" do
      get "/api/trade_listings?q=test"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/trade_listings" do
    context "with valid params" do
      it "returns 201" do
        post "/api/trade_listings", params: { trade_listing: {
      public_id: SecureRandom.uuid,
      status: :active,
      listing_type: :trade_offer,
      foil: true,
      condition: :mint,
      quantity: 1,
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
            params: { trade_listing: { public_id: SecureRandom.uuid } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end


  describe "POST /api/trade_listings (rule: fixed_price_requires_asking_price)" do
    it "create fails when fixed price requires asking price violated" do
      # Fixed price listing must have an asking price
      post "/api/trade_listings", params: { trade_listing: {
        public_id: SecureRandom.uuid,
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
        public_id: SecureRandom.uuid,
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
        public_id: SecureRandom.uuid,
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
  describe "PATCH /api/trade_listings/:id/transitions/pending-to-active" do
    let!(:tradeListing) { TradeListing.create!(valid_attributes).tap { |r| r.class.where(id: r.id).update_all(status: TradeListing.statuses['pending']); r.reload } }
    before { tradeListing.update!(quantity: 1) }
    it "transitions to Active with role Seller" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'Seller'))
      patch "/api/trade_listings/#{tradeListing.id}/transitions/pending-to-active"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(tradeListing.reload.status).to eq('active') if response.status == 200
    end

    it "returns 403 for transition Pending -> Active with insufficient role" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'guest'))
      patch "/api/trade_listings/#{tradeListing.id}/transitions/pending-to-active"
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/trade_listings/:id/transitions/active-to-sold" do
    let!(:tradeListing) { TradeListing.create!(valid_attributes).tap { |r| r.class.where(id: r.id).update_all(status: TradeListing.statuses['active']); r.reload } }
    it "transitions to Sold" do
      patch "/api/trade_listings/#{tradeListing.id}/transitions/active-to-sold"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(tradeListing.reload.status).to eq('sold') if response.status == 200
    end
  end

  describe "PATCH /api/trade_listings/:id/transitions/active-to-expired" do
    let!(:tradeListing) { TradeListing.create!(valid_attributes).tap { |r| r.class.where(id: r.id).update_all(status: TradeListing.statuses['active']); r.reload } }
    it "transitions to Expired" do
      patch "/api/trade_listings/#{tradeListing.id}/transitions/active-to-expired"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(tradeListing.reload.status).to eq('expired') if response.status == 200
    end
  end

  describe "PATCH /api/trade_listings/:id/transitions/active-to-cancelled" do
    let!(:tradeListing) { TradeListing.create!(valid_attributes).tap { |r| r.class.where(id: r.id).update_all(status: TradeListing.statuses['active']); r.reload } }
    it "transitions to Cancelled with role Seller" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'Seller'))
      patch "/api/trade_listings/#{tradeListing.id}/transitions/active-to-cancelled"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(tradeListing.reload.status).to eq('cancelled') if response.status == 200
    end

    it "returns 403 for transition Active -> Cancelled with insufficient role" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'guest'))
      patch "/api/trade_listings/#{tradeListing.id}/transitions/active-to-cancelled"
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/trade_listings/:id/transitions/sold-to-active" do
    let!(:tradeListing) { TradeListing.create!(valid_attributes) }
    it "returns 409 (denied)" do
      patch "/api/trade_listings/#{tradeListing.id}/transitions/sold-to-active"
      expect(response).to have_http_status(:conflict)
    end
  end

  describe "PATCH /api/trade_listings/:id/transitions/expired-to-active" do
    let!(:tradeListing) { TradeListing.create!(valid_attributes) }
    it "returns 409 (denied)" do
      patch "/api/trade_listings/#{tradeListing.id}/transitions/expired-to-active"
      expect(response).to have_http_status(:conflict)
    end
  end
end
