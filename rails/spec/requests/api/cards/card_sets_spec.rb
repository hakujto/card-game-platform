require 'rails_helper'

RSpec.describe "Api::Cards::CardSets", type: :request do
  let(:valid_attributes) do
    {
      name: 'test',
      code: 'test',
      release_date: Date.today,
      set_type: :core,
      total_cards: 1,
      is_rotated: false
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
        post "/api/card_sets", params: { card_set: {
      name: 'test',
      code: 'test',
      release_date: Date.today,
      set_type: :core,
      total_cards: 1,
      is_rotated: false
        } }, as: :json
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

  describe "POST /api/card_sets (rule: total_cards_positive)" do
    it "create fails when total cards positive violated" do
      # Card set must have at least one card
      post "/api/card_sets", params: { card_set: {
        name: 'test',
        code: 'test',
        release_date: Date.today,
        rotation_date: Date.today,
        total_cards: 0,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/card_sets (rule: rotation_date_after_release)" do
    it "create fails when rotation date after release violated" do
      # Rotation date must be after release date
      post "/api/card_sets", params: { card_set: {
        name: 'test',
        code: 'test',
        release_date: Date.today,
        total_cards: 1,
        rotation_date: Date.today - 1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/card_sets (rule: rotated_set_has_rotation_date)" do
    it "create fails when rotated set has rotation date violated" do
      # Rotated set must have a rotation date
      post "/api/card_sets", params: { card_set: {
        name: 'test',
        code: 'test',
        release_date: Date.today,
        total_cards: 1,
        is_rotated: true,
        rotation_date: nil,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
