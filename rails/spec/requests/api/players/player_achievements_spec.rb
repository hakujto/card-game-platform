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

  describe "GET /api/player_achievements/:id" do
    let!(:playerAchievement) { PlayerAchievement.create!(valid_attributes) }

    it "returns 200" do
      get "/api/player_achievements/#{playerAchievement.id}"
      expect(response).to have_http_status(:ok)
    end
  end

end
