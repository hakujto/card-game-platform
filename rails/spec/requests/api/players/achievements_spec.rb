require 'rails_helper'

RSpec.describe "Api::Players::Achievements", type: :request do
  let(:valid_attributes) do
    {
      name: 'test',
      description: 'test',
      points: 1,
      rarity: :common,
      is_hidden: true
    }
  end

  describe "GET /api/achievements" do
    it "returns 200" do
      get "/api/achievements"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/achievements" do
    context "with valid params" do
      it "returns 201" do
        post "/api/achievements", params: { achievement: {
      name: 'test',
      description: 'test',
      points: 1,
      rarity: :common,
      is_hidden: true
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/achievements/:id" do
    let!(:achievement) { Achievement.create!(valid_attributes) }

    it "returns 200" do
      get "/api/achievements/#{achievement.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/achievements/:id" do
    let!(:achievement) { Achievement.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/achievements/#{achievement.id}",
            params: { achievement: { name: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/achievements/:id" do
    let!(:achievement) { Achievement.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/achievements/#{achievement.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/achievements (rule: points_positive)" do
    it "create fails when points positive violated" do
      # Achievement must award at least one point
      post "/api/achievements", params: { achievement: {
        name: 'test',
        description: 'test',
        points: 0,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
