require 'rails_helper'

RSpec.describe "Api::Players::PlayerAchievements", type: :request do
  before(:each) do
    @dep_player = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @dep_achievement = Achievement.create!({ name: 'test', description: 'test', points: 1, rarity: :common, is_hidden: true })
  end

  let(:valid_attributes) do
    {
      earned_at: Time.now,
      progress: 1,
      is_completed: false,
      player_id: @dep_player.id,
      achievement_id: @dep_achievement.id
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
        post "/api/player_achievements", params: { player_achievement: {
      earned_at: Time.now,
      progress: 1,
      is_completed: false,
      player_id: @dep_player.id,
      achievement_id: @dep_achievement.id
        } }, as: :json
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

  describe "POST /api/player_achievements (rule: completed_requires_progress)" do
    it "create fails when completed requires progress violated" do
      # Completed achievement must have progress greater than zero
      post "/api/player_achievements", params: { player_achievement: {
        earned_at: Time.now,
        player_id: 1,
        achievement_id: 1,
        is_completed: true,
        progress: 0,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/player_achievements (rule: progress_not_negative)" do
    it "create fails when progress not negative violated" do
      # Achievement progress must not be negative
      post "/api/player_achievements", params: { player_achievement: {
        earned_at: Time.now,
        player_id: 1,
        achievement_id: 1,
        progress: -1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
