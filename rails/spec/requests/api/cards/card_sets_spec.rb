require 'rails_helper'

RSpec.describe "Api::Cards::CardSets", type: :request do
  let(:valid_attributes) do
    {
        name: 'test',
        code: 'test',
        release_date: Date.today,
        total_cards: 1
    }
  end

  describe "GET /api/card_sets" do
    it "returns 200" do
      get "/api/card_sets"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/card_sets" do
    context "with valid params" do
      it "returns 201" do
        post "/api/card_sets", params: { card_set: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/card_sets/:id" do
    let!(:cardSet) { CardSet.create!(valid_attributes) }

    it "returns 200" do
      get "/api/card_sets/#{cardSet.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/card_sets/:id" do
    let!(:cardSet) { CardSet.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/card_sets/#{cardSet.id}",
            params: { card_set: { name: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/card_sets/:id" do
    let!(:cardSet) { CardSet.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/card_sets/#{cardSet.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
