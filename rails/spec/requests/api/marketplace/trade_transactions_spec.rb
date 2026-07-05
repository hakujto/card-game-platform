require 'rails_helper'

RSpec.describe "Api::Marketplace::TradeTransactions", type: :request do
  before(:each) do
    @aux_player = Player.create!({ public_id: SecureRandom.uuid, display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @aux_card_set = CardSet.create!({ name: 'test', code: 'AB', release_date: Date.today, rotation_date: nil, set_type: :core, total_cards: 1, is_rotated: false })
    @aux_card = Card.create!({ public_id: SecureRandom.uuid, name: 'test', card_type: :spell, rarity: :common, mana_cost: 0, mana_colors: :white, attack: 1, defense: 1, loyalty: nil, description: 'test', legal_formats: :standard, is_banned: false, is_restricted: false, power_level: 1, total_copies_in_circulation: 1, set_id: @aux_card_set.id })
    @dep_listing = TradeListing.create!({ public_id: SecureRandom.uuid, status: :active, listing_type: :trade_offer, asking_price: '0.00', auction_start_price: '0.00', auction_end_time: Time.now, foil: true, condition: :mint, quantity: 1, created_at: Time.now, seller_id: @aux_player.id, card_id: @aux_card.id })
  end

  let(:valid_attributes) do
    {
      final_price: '0.01',
      platform_fee: '0.01',
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

  describe "GET /api/trade_transactions/:id" do
    let!(:tradeTransaction) { TradeTransaction.create!(valid_attributes) }

    it "returns 200" do
      get "/api/trade_transactions/#{tradeTransaction.id}"
      expect(response).to have_http_status(:ok)
    end
  end

end
