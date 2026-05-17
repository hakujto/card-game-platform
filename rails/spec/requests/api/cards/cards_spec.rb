require 'rails_helper'

RSpec.describe "Api::Cards::Cards", type: :request do
  before(:each) do
    @dep_set = CardSet.create!({ name: 'test', code: 'test', release_date: Date.today, set_type: :core, total_cards: 1 })
  end

  let(:valid_attributes) do
    {
      name: 'test',
      card_type: :spell,
      rarity: :common,
      mana_cost: 1,
      mana_colors: :white,
      description: 'test',
      legal_formats: :standard,
      is_banned: false,
      is_restricted: false,
      power_level: 1,
      set_id: @dep_set.id
    }
  end

  describe "GET /api/cards" do
    it "returns 200" do
      get "/api/cards"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/cards" do
    context "with valid params" do
      it "returns 201" do
        post "/api/cards", params: { card: {
      name: 'test',
      card_type: :spell,
      rarity: :common,
      mana_cost: 1,
      mana_colors: :white,
      description: 'test',
      legal_formats: :standard,
      is_banned: false,
      is_restricted: false,
      power_level: 1,
      set_id: @dep_set.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/cards/:id" do
    let!(:card) { Card.create!(valid_attributes) }

    it "returns 200" do
      get "/api/cards/#{card.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/cards/:id" do
    let!(:card) { Card.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/cards/#{card.id}",
            params: { card: { name: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/cards/:id" do
    let!(:card) { Card.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/cards/#{card.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/cards (rule: creature_requires_stats)" do
    it "create fails when creature requires stats violated" do
      # Creature card must have attack and defense
      post "/api/cards", params: { card: {
        name: 'test',
        mana_colors: :white,
        description: 'test',
        legal_formats: :standard,
        set_id: 1,
        card_type: :creature,
        attack: nil,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/cards (rule: planeswalker_requires_loyalty)" do
    it "create fails when planeswalker requires loyalty violated" do
      # Planeswalker card must have loyalty
      post "/api/cards", params: { card: {
        name: 'test',
        mana_colors: :white,
        description: 'test',
        legal_formats: :standard,
        set_id: 1,
        card_type: :planeswalker,
        loyalty: nil,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/cards (rule: mana_cost_range)" do
    it "create fails when mana cost range violated" do
      # mana_cost must be between 0 and 20
      post "/api/cards", params: { card: {
        name: 'test',
        mana_colors: :white,
        description: 'test',
        legal_formats: :standard,
        set_id: 1,
        attack: 1,
        defense: 1,
        loyalty: 1,
        mana_cost: 21,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/cards (rule: power_level_range)" do
    it "create fails when power level range violated" do
      # power_level must be between 1 and 10
      post "/api/cards", params: { card: {
        name: 'test',
        mana_colors: :white,
        description: 'test',
        legal_formats: :standard,
        set_id: 1,
        attack: 1,
        defense: 1,
        loyalty: 1,
        power_level: 11,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/cards (rule: not_banned_and_restricted)" do
    it "create fails when not banned and restricted violated" do
      # Card cannot be both banned and restricted at the same time
      post "/api/cards", params: { card: {
        name: 'test',
        mana_colors: :white,
        description: 'test',
        legal_formats: :standard,
        set_id: 1,
        attack: 1,
        defense: 1,
        loyalty: 1,
        is_banned: true,
        is_restricted: true,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
