require 'rails_helper'

RSpec.describe "Api::Cards::CardRulings", type: :request do
  before(:each) do
    @aux_card_set = CardSet.create!({ name: 'test', code: 'test', release_date: Date.today, set_type: :core, total_cards: 1 })
    @dep_card = Card.create!({ name: 'test', card_type: :spell, rarity: :common, mana_cost: 1, mana_colors: :white, description: 'test', legal_formats: :standard, is_banned: false, is_restricted: false, power_level: 1, set_id: @aux_card_set.id })
  end

  let(:valid_attributes) do
    {
      ruling_text: 'test',
      published_at: Date.today,
      source: 'test',
      card_id: @dep_card.id
    }
  end

  describe "GET /api/card_rulings" do
    it "returns 200" do
      get "/api/card_rulings"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/card_rulings" do
    context "with valid params" do
      it "returns 201" do
        post "/api/card_rulings", params: { card_ruling: {
      ruling_text: 'test',
      published_at: Date.today,
      source: 'test',
      card_id: @dep_card.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/card_rulings/:id" do
    let!(:cardRuling) { CardRuling.create!(valid_attributes) }

    it "returns 200" do
      get "/api/card_rulings/#{cardRuling.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/card_rulings/:id" do
    let!(:cardRuling) { CardRuling.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/card_rulings/#{cardRuling.id}",
            params: { card_ruling: { ruling_text: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/card_rulings/:id" do
    let!(:cardRuling) { CardRuling.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/card_rulings/#{cardRuling.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
