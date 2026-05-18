require 'rails_helper'

RSpec.describe "Api::Cards::Decks", type: :request do
  before(:each) do
    @dep_player = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
  end

  let(:valid_attributes) do
    {
      name: 'test',
      format: :standard,
      is_public: true,
      is_tournament_legal: false,
      wins: 1,
      losses: 1,
      draws: 1,
      created_at: Time.now,
      updated_at: Time.now,
      player_id: @dep_player.id
    }
  end

  describe "GET /api/decks" do
    it "returns 200" do
      get "/api/decks"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/decks" do
    context "with valid params" do
      it "returns 201" do
        post "/api/decks", params: { deck: {
      name: 'test',
      format: :standard,
      is_public: true,
      is_tournament_legal: false,
      wins: 1,
      losses: 1,
      draws: 1,
      created_at: Time.now,
      updated_at: Time.now,
      player_id: @dep_player.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/decks/:id" do
    let!(:deck) { Deck.create!(valid_attributes) }

    it "returns 200" do
      get "/api/decks/#{deck.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/decks/:id" do
    let!(:deck) { Deck.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/decks/#{deck.id}",
            params: { deck: { name: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/decks/:id" do
    let!(:deck) { Deck.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/decks/#{deck.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/decks (rule: wins_not_negative)" do
    it "create fails when wins not negative violated" do
      # Deck wins count must not be negative
      post "/api/decks", params: { deck: {
        name: 'test',
        created_at: Time.now,
        updated_at: Time.now,
        player_id: 1,
        is_public: true,
        wins: -1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/decks (rule: losses_not_negative)" do
    it "create fails when losses not negative violated" do
      # Deck losses count must not be negative
      post "/api/decks", params: { deck: {
        name: 'test',
        created_at: Time.now,
        updated_at: Time.now,
        player_id: 1,
        is_public: true,
        losses: -1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/decks (rule: draws_not_negative)" do
    it "create fails when draws not negative violated" do
      # Deck draws count must not be negative
      post "/api/decks", params: { deck: {
        name: 'test',
        created_at: Time.now,
        updated_at: Time.now,
        player_id: 1,
        is_public: true,
        draws: -1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/decks (rule: tournament_legal_deck_must_be_validated)" do
    it "create fails when tournament legal deck must be validated violated" do
      # Tournament-legal deck must be made public
      post "/api/decks", params: { deck: {
        name: 'test',
        created_at: Time.now,
        updated_at: Time.now,
        player_id: 1,
        is_tournament_legal: true,
        is_public: false,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
