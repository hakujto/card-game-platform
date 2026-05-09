require 'rails_helper'

RSpec.describe "Api::Cards::CardAbilities", type: :request do
  let(:valid_attributes) do
    {
        ability_text: 'test'
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
        post "/api/card_abilities", params: { card_ability: valid_attributes }, as: :json
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
            params: { card_ability: { ability_type: 'test' } },
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
end
