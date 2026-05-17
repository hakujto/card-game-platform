require 'rails_helper'

RSpec.describe "Api::Cards::DeckTags", type: :request do
  let(:valid_attributes) do
    {
      name: 'test'
    }
  end

  describe "GET /api/deck_tags" do
    it "returns 200" do
      get "/api/deck_tags"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/deck_tags" do
    context "with valid params" do
      it "returns 201" do
        post "/api/deck_tags", params: { deck_tag: {
      name: 'test'
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/deck_tags/:id" do
    let!(:deckTag) { DeckTag.create!(valid_attributes) }

    it "returns 200" do
      get "/api/deck_tags/#{deckTag.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/deck_tags/:id" do
    let!(:deckTag) { DeckTag.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/deck_tags/#{deckTag.id}",
            params: { deck_tag: { name: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/deck_tags/:id" do
    let!(:deckTag) { DeckTag.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/deck_tags/#{deckTag.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
