require 'rails_helper'

RSpec.describe "Api::Tournaments::TournamentJudges", type: :request do
  before(:each) do
    @aux_season = Season.create!({ name: 'test', start_date: Date.today, end_date: Date.today + 1, format: :standard, is_active: true })
    @aux_player = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @dep_tournament = Tournament.create!({ name: 'test', format: :standard, tournament_type: :swiss, status: :draft, max_players: 2, entry_fee: '0.00', prize_pool: '0.00', start_time: Time.now, end_time: nil, is_online: true, created_at: Time.now, season_id: @aux_season.id, organizer_id: @aux_player.id })
  end

  let(:valid_attributes) do
    {
      role: :head_judge,
      tournament_id: @dep_tournament.id,
      player_id: @aux_player.id
    }
  end

  describe "GET /api/tournament_judges" do
    it "returns 200" do
      get "/api/tournament_judges"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/tournament_judges" do
    context "with valid params" do
      it "returns 201" do
        post "/api/tournament_judges", params: { tournament_judge: {
      role: :head_judge,
      tournament_id: @dep_tournament.id,
      player_id: @aux_player.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/tournament_judges/:id" do
    let!(:tournamentJudge) { TournamentJudge.create!(valid_attributes) }

    it "returns 200" do
      get "/api/tournament_judges/#{tournamentJudge.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/tournament_judges/:id" do
    let!(:tournamentJudge) { TournamentJudge.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/tournament_judges/#{tournamentJudge.id}",
            params: { tournament_judge: { role: :head_judge } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/tournament_judges/:id" do
    let!(:tournamentJudge) { TournamentJudge.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/tournament_judges/#{tournamentJudge.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
