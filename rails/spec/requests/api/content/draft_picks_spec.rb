require 'rails_helper'

RSpec.describe "Api::Content::DraftPicks", type: :request do
  before(:each) do
    @aux_card_set = CardSet.create!({ name: 'test', code: 'test', release_date: Date.today, set_type: :core, total_cards: 1 })
    @aux_draft_session = DraftSession.create!({ status: :waiting_for_players, draft_type: :booster, seats: 1, created_at: Time.now, card_set_id: @aux_card_set.id })
    @aux_player = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @dep_participant = DraftParticipant.create!({ seat_number: 1, joined_at: Time.now, session_id: @aux_draft_session.id, player_id: @aux_player.id })
    @dep_card = Card.create!({ name: 'test', card_type: :spell, rarity: :common, mana_cost: 1, mana_colors: :white, description: 'test', legal_formats: :standard, is_banned: false, is_restricted: false, power_level: 1, set_id: @aux_card_set.id })
  end

  let(:valid_attributes) do
    {
      pick_number: 1,
      pack_number: 1,
      picked_at: Time.now,
      participant_id: @dep_participant.id,
      card_id: @dep_card.id
    }
  end

  describe "GET /api/draft_picks" do
    it "returns 200" do
      get "/api/draft_picks"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/draft_picks" do
    context "with valid params" do
      it "returns 201" do
        post "/api/draft_picks", params: { draft_pick: {
      pick_number: 1,
      pack_number: 1,
      picked_at: Time.now,
      participant_id: @dep_participant.id,
      card_id: @dep_card.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/draft_picks/:id" do
    let!(:draftPick) { DraftPick.create!(valid_attributes) }

    it "returns 200" do
      get "/api/draft_picks/#{draftPick.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/draft_picks/:id" do
    let!(:draftPick) { DraftPick.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/draft_picks/#{draftPick.id}",
            params: { draft_pick: { pick_number: 1 } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/draft_picks/:id" do
    let!(:draftPick) { DraftPick.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/draft_picks/#{draftPick.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
