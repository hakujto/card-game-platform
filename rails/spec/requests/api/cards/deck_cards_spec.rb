require 'rails_helper'

RSpec.describe "Api::Cards::DeckCards", type: :request do
  before(:each) do
    @aux_player = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @dep_deck = Deck.create!({ name: 'test', format: :standard, is_public: true, is_tournament_legal: false, wins: 1, losses: 1, draws: 1, created_at: Time.now, updated_at: Time.now, player_id: @aux_player.id })
    @aux_card_set = CardSet.create!({ name: 'test', code: 'test', release_date: Date.today, rotation_date: nil, set_type: :core, total_cards: 1, is_rotated: false })
    @dep_card = Card.create!({ name: 'test', card_type: :spell, rarity: :common, mana_cost: 1, mana_colors: :white, attack: 1, defense: 1, loyalty: nil, description: 'test', legal_formats: :standard, is_banned: false, is_restricted: false, power_level: 1, set_id: @aux_card_set.id })
  end

  let(:valid_attributes) do
    {
      quantity: 1,
      is_commander: true,
      deck_id: @dep_deck.id,
      card_id: @dep_card.id
    }
  end

  describe "GET /api/deck_cards" do
    it "returns 200" do
      get "/api/deck_cards"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/deck_cards" do
    context "with valid params" do
      it "returns 201" do
        post "/api/deck_cards", params: { deck_card: {
      quantity: 1,
      is_commander: true,
      deck_id: @dep_deck.id,
      card_id: @dep_card.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/deck_cards/:id" do
    let!(:deckCard) { DeckCard.create!(valid_attributes) }

    it "returns 200" do
      get "/api/deck_cards/#{deckCard.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/deck_cards/:id" do
    let!(:deckCard) { DeckCard.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/deck_cards/#{deckCard.id}",
            params: { deck_card: { quantity: 1 } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/deck_cards/:id" do
    let!(:deckCard) { DeckCard.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/deck_cards/#{deckCard.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/deck_cards (rule: quantity_range)" do
    it "create fails when quantity range violated" do
      # A deck can contain between 1 and 4 copies of a card
      post "/api/deck_cards", params: { deck_card: {
        deck_id: 1,
        card_id: 1,
        quantity: 5,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
