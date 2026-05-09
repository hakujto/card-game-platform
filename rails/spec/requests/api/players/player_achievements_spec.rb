require 'rails_helper'

RSpec.describe "Api::Players::PlayerAchievements", type: :request do
  let(:valid_attributes) do
    {
        earned_at: Time.now,
        progress: 1,
        is_completed: true
    }
  end

  describe "GET /api/player_achievements" do
    it "returns 200" do
      get "/api/player_achievements"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/player_achievements" do
    context "with valid params" do
      it "returns 201" do
        post "/api/player_achievements", params: { player_achievement: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/player_achievements/:id" do
    let!(:playerAchievement) { PlayerAchievement.create!(valid_attributes) }

    it "returns 200" do
      get "/api/player_achievements/#{playerAchievement.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/player_achievements/:id" do
    let!(:playerAchievement) { PlayerAchievement.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/player_achievements/#{playerAchievement.id}",
            params: { player_achievement: { earned_at: Time.now } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/player_achievements/:id" do
    let!(:playerAchievement) { PlayerAchievement.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/player_achievements/#{playerAchievement.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
