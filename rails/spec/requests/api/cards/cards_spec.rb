require 'rails_helper'

RSpec.describe "Api::Cards::Cards", type: :request do
  let(:valid_attributes) do
    {
        name: 'test',
        mana_cost: 1,
        description: 'test',
        is_banned: true,
        is_restricted: true,
        power_level: 1
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
        post "/api/cards", params: { card: valid_attributes }, as: :json
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
end
