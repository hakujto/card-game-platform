require 'rails_helper'

RSpec.describe "Api::Cards::CardAbilities", type: :request do
  before(:each) do
    @aux_card_set = CardSet.create!({ name: 'test', code: 'test', release_date: Date.today, set_type: :core, total_cards: 1 })
    @dep_card = Card.create!({ name: 'test', card_type: :spell, rarity: :common, mana_cost: 1, mana_colors: :white, description: 'test', legal_formats: :standard, is_banned: false, is_restricted: false, power_level: 1, set_id: @aux_card_set.id })
  end

  let(:valid_attributes) do
    {
      ability_type: :activated,
      ability_text: 'test',
      card_id: @dep_card.id
    }
  end

  describe "GET /api/card_abilities" do
    it "returns 200" do
      get "/api/card_abilities"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/card_abilities" do
    context "with valid params" do
      it "returns 201" do
        post "/api/card_abilities", params: { card_ability: {
      ability_type: :activated,
      ability_text: 'test',
      card_id: @dep_card.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/card_abilities/:id" do
    let!(:cardAbility) { CardAbility.create!(valid_attributes) }

    it "returns 200" do
      get "/api/card_abilities/#{cardAbility.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/card_abilities/:id" do
    let!(:cardAbility) { CardAbility.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/card_abilities/#{cardAbility.id}",
            params: { card_ability: { ability_text: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/card_abilities/:id" do
    let!(:cardAbility) { CardAbility.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/card_abilities/#{cardAbility.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/card_abilities (rule: keyword_ability_requires_keyword)" do
    it "create fails when keyword ability requires keyword violated" do
      # Keyword ability must have a keyword name
      post "/api/card_abilities", params: { card_ability: {
        ability_text: 'test',
        card_id: 1,
        ability_type: :keyword,
        keyword: nil,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
