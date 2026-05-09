require 'rails_helper'

RSpec.describe "Api::Cards::CardRulings", type: :request do
  let(:valid_attributes) do
    {
        ruling_text: 'test',
        published_at: Date.today,
        source: 'test'
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
        post "/api/card_rulings", params: { card_ruling: valid_attributes }, as: :json
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
