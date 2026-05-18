require 'rails_helper'

RSpec.describe "Api::Tournaments::AwardedPrizes", type: :request do
  before(:each) do
    @aux_season = Season.create!({ name: 'test', start_date: Date.today, end_date: Date.today + 1, format: :standard, is_active: true })
    @aux_player = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @aux_tournament = Tournament.create!({ name: 'test', format: :standard, tournament_type: :swiss, status: :draft, max_players: 2, entry_fee: '0.00', prize_pool: '0.00', start_time: Time.now, end_time: nil, is_online: true, created_at: Time.now, season_id: @aux_season.id, organizer_id: @aux_player.id })
    @dep_prize = TournamentPrize.create!({ placement_from: 1, placement_to: 1, prize_type: :currency, amount: '0.00', season_points: 1, tournament_id: @aux_tournament.id })
  end

  let(:valid_attributes) do
    {
      final_placement: 1,
      awarded_at: Time.now,
      claimed: false,
      prize_id: @dep_prize.id,
      player_id: @aux_player.id
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
        post "/api/awarded_prizes", params: { awarded_prize: {
      final_placement: 1,
      awarded_at: Time.now,
      claimed: false,
      prize_id: @dep_prize.id,
      player_id: @aux_player.id
        } }, as: :json
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
            params: { awarded_prize: { awarded_at: Time.now } },
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

  describe "POST /api/awarded_prizes (rule: claimed_requires_claimed_at)" do
    it "create fails when claimed requires claimed at violated" do
      # Claimed prize must have a claimed_at timestamp
      post "/api/awarded_prizes", params: { awarded_prize: {
        final_placement: 1,
        awarded_at: Time.now,
        prize_id: 1,
        player_id: 1,
        claimed: true,
        claimed_at: nil,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/awarded_prizes (rule: final_placement_positive)" do
    it "create fails when final placement positive violated" do
      # Final placement must be greater than zero
      post "/api/awarded_prizes", params: { awarded_prize: {
        awarded_at: Time.now,
        prize_id: 1,
        player_id: 1,
        claimed_at: Time.now,
        final_placement: 0,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
