require 'rails_helper'

RSpec.describe "Api::Players::PlayerCollections", type: :request do
  before(:each) do
    @dep_player = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @aux_card_set = CardSet.create!({ name: 'test', code: 'test', release_date: Date.today, set_type: :core, total_cards: 1 })
    @dep_card = Card.create!({ name: 'test', card_type: :spell, rarity: :common, mana_cost: 1, mana_colors: :white, description: 'test', legal_formats: :standard, is_banned: false, is_restricted: false, power_level: 1, set_id: @aux_card_set.id })
  end

  let(:valid_attributes) do
    {
      quantity: 1,
      foil: true,
      condition: :mint,
      acquired_at: Time.now,
      acquired_via: :purchase,
      player_id: @dep_player.id,
      card_id: @dep_card.id
    }
  end

  describe "GET /api/player_collections" do
    it "returns 200" do
      get "/api/player_collections"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/player_collections" do
    context "with valid params" do
      it "returns 201" do
        post "/api/player_collections", params: { player_collection: {
      quantity: 1,
      foil: true,
      condition: :mint,
      acquired_at: Time.now,
      acquired_via: :purchase,
      player_id: @dep_player.id,
      card_id: @dep_card.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/player_collections/:id" do
    let!(:playerCollection) { PlayerCollection.create!(valid_attributes) }

    it "returns 200" do
      get "/api/player_collections/#{playerCollection.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/player_collections/:id" do
    let!(:playerCollection) { PlayerCollection.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/player_collections/#{playerCollection.id}",
            params: { player_collection: { quantity: 1 } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/player_collections/:id" do
    let!(:playerCollection) { PlayerCollection.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/player_collections/#{playerCollection.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
