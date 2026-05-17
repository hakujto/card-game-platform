require 'rails_helper'

RSpec.describe "Api::Cards::DeckTagAssignments", type: :request do
  before(:each) do
    @aux_player = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @dep_deck = Deck.create!({ name: 'test', format: :standard, is_public: true, is_tournament_legal: true, wins: 1, losses: 1, created_at: Time.now, updated_at: Time.now, player_id: @aux_player.id })
    @dep_tag = DeckTag.create!({ name: 'test' })
  end

  let(:valid_attributes) do
    {
      deck_id: @dep_deck.id,
      tag_id: @dep_tag.id
    }
  end

  describe "GET /api/deck_tag_assignments" do
    it "returns 200" do
      get "/api/deck_tag_assignments"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/deck_tag_assignments" do
    context "with valid params" do
      it "returns 201" do
        post "/api/deck_tag_assignments", params: { deck_tag_assignment: {
      deck_id: @dep_deck.id,
      tag_id: @dep_tag.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/deck_tag_assignments/:id" do
    let!(:deckTagAssignment) { DeckTagAssignment.create!(valid_attributes) }

    it "returns 200" do
      get "/api/deck_tag_assignments/#{deckTagAssignment.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/deck_tag_assignments/:id" do
    let!(:deckTagAssignment) { DeckTagAssignment.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/deck_tag_assignments/#{deckTagAssignment.id}",
            params: { deck_tag_assignment: {  } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/deck_tag_assignments/:id" do
    let!(:deckTagAssignment) { DeckTagAssignment.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/deck_tag_assignments/#{deckTagAssignment.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
