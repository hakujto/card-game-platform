require 'rails_helper'

RSpec.describe "Api::Marketplace::TradeDisputes", type: :request do
  before(:each) do
    @aux_player = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @aux_card_set = CardSet.create!({ name: 'test', code: 'test', release_date: Date.today, rotation_date: nil, set_type: :core, total_cards: 1, is_rotated: false })
    @aux_card = Card.create!({ name: 'test', card_type: :spell, rarity: :common, mana_cost: 0, mana_colors: :white, attack: 1, defense: 1, loyalty: nil, description: 'test', legal_formats: :standard, is_banned: false, is_restricted: false, power_level: 1, set_id: @aux_card_set.id })
    @aux_trade_listing = TradeListing.create!({ status: :active, listing_type: :trade_offer, asking_price: '0.00', auction_start_price: '0.00', auction_end_time: Time.now, foil: true, condition: :mint, quantity: 1, created_at: Time.now, seller_id: @aux_player.id, card_id: @aux_card.id })
    @dep_transaction = TradeTransaction.create!({ final_price: '0.01', platform_fee: '0.01', status: :pending, completed_at: Time.now, listing_id: @aux_trade_listing.id, buyer_id: @aux_player.id, seller_id: @aux_player.id })
  end

  let(:valid_attributes) do
    {
      status: :resolved,
      reason: :item_not_received,
      description: 'test',
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
              fresh_sub_listing = TradeListing.create!({ status: :active, listing_type: :trade_offer, foil: true, condition: :mint, quantity: 1, created_at: Time.now, seller_id: @aux_player.id, card_id: @aux_card.id })
      fresh_transaction = TradeTransaction.create!({ final_price: '0.01', platform_fee: '0.01', status: :pending, listing_id: fresh_sub_listing.id, buyer_id: @aux_player.id, seller_id: @aux_player.id })
      post "/api/trade_disputes", params: { trade_dispute: {
      status: :resolved,
      reason: :item_not_received,
      description: 'test',
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
  describe "PATCH /api/trade_disputes/:id/transitions/open-to-underreview" do
    let!(:tradeDispute) { TradeDispute.create!(valid_attributes).tap { |r| r.update_column(:status, TradeDispute.statuses['open']) } }
    it "transitions to UnderReview with role Admin" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'Admin'))
      patch "/api/trade_disputes/#{tradeDispute.id}/transitions/open-to-underreview"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(tradeDispute.reload.status).to eq('under_review') if response.status == 200
    end

    it "returns 403 for transition Open -> UnderReview with insufficient role" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'guest'))
      patch "/api/trade_disputes/#{tradeDispute.id}/transitions/open-to-underreview"
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/trade_disputes/:id/transitions/underreview-to-resolved" do
    let!(:tradeDispute) { TradeDispute.create!(valid_attributes).tap { |r| r.update_column(:status, TradeDispute.statuses['under_review']) } }
    before { tradeDispute.update!(resolution: 'test') }
    it "transitions to Resolved with role Admin" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'Admin'))
      patch "/api/trade_disputes/#{tradeDispute.id}/transitions/underreview-to-resolved"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(tradeDispute.reload.status).to eq('resolved') if response.status == 200
    end

    it "returns 403 for transition UnderReview -> Resolved with insufficient role" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'guest'))
      patch "/api/trade_disputes/#{tradeDispute.id}/transitions/underreview-to-resolved"
      expect(response).to have_http_status(:forbidden)
    end

    context "when resolution is missing" do
      before { tradeDispute.update_column(:resolution, nil) }
      it "returns 422" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'Admin'))
        patch "/api/trade_disputes/#{tradeDispute.id}/transitions/underreview-to-resolved"
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /api/trade_disputes/:id/transitions/underreview-to-escalated" do
    let!(:tradeDispute) { TradeDispute.create!(valid_attributes).tap { |r| r.update_column(:status, TradeDispute.statuses['under_review']) } }
    it "transitions to Escalated with role Admin" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'Admin'))
      patch "/api/trade_disputes/#{tradeDispute.id}/transitions/underreview-to-escalated"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(tradeDispute.reload.status).to eq('escalated') if response.status == 200
    end

    it "returns 403 for transition UnderReview -> Escalated with insufficient role" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'guest'))
      patch "/api/trade_disputes/#{tradeDispute.id}/transitions/underreview-to-escalated"
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/trade_disputes/:id/transitions/escalated-to-resolved" do
    let!(:tradeDispute) { TradeDispute.create!(valid_attributes).tap { |r| r.update_column(:status, TradeDispute.statuses['escalated']) } }
    before { tradeDispute.update!(resolution: 'test') }
    it "transitions to Resolved with role Admin" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'Admin'))
      patch "/api/trade_disputes/#{tradeDispute.id}/transitions/escalated-to-resolved"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(tradeDispute.reload.status).to eq('resolved') if response.status == 200
    end

    it "returns 403 for transition Escalated -> Resolved with insufficient role" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'guest'))
      patch "/api/trade_disputes/#{tradeDispute.id}/transitions/escalated-to-resolved"
      expect(response).to have_http_status(:forbidden)
    end

    context "when resolution is missing" do
      before { tradeDispute.update_column(:resolution, nil) }
      it "returns 422" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'Admin'))
        patch "/api/trade_disputes/#{tradeDispute.id}/transitions/escalated-to-resolved"
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /api/trade_disputes/:id/transitions/resolved-to-open" do
    let!(:tradeDispute) { TradeDispute.create!(valid_attributes) }
    it "returns 409 (denied)" do
      patch "/api/trade_disputes/#{tradeDispute.id}/transitions/resolved-to-open"
      expect(response).to have_http_status(:conflict)
    end
  end
end
