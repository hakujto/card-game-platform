require 'rails_helper'

RSpec.describe "Api::Tournaments::AwardedPrizes", type: :request do
  let(:valid_attributes) do
    {
        final_placement: 1,
        awarded_at: Time.now,
        claimed: true
    }
  end

  describe "GET /api/awarded_prizes" do
    it "returns 200" do
      get "/api/awarded_prizes"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/awarded_prizes" do
    context "with valid params" do
      it "returns 201" do
        post "/api/awarded_prizes", params: { awarded_prize: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/awarded_prizes/:id" do
    let!(:awardedPrize) { AwardedPrize.create!(valid_attributes) }

    it "returns 200" do
      get "/api/awarded_prizes/#{awardedPrize.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/awarded_prizes/:id" do
    let!(:awardedPrize) { AwardedPrize.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/awarded_prizes/#{awardedPrize.id}",
            params: { awarded_prize: { final_placement: 1 } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/awarded_prizes/:id" do
    let!(:awardedPrize) { AwardedPrize.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/awarded_prizes/#{awardedPrize.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
