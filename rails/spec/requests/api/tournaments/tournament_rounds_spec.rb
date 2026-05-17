require 'rails_helper'

RSpec.describe "Api::Tournaments::TournamentRounds", type: :request do
  before(:each) do
    @aux_season = Season.create!({ name: 'test', start_date: Date.today, end_date: Date.today + 1, format: :standard, is_active: true })
    @aux_player = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @dep_tournament = Tournament.create!({ name: 'test', format: :standard, tournament_type: :swiss, status: :draft, max_players: 2, entry_fee: '0.00', prize_pool: '0.00', start_time: Time.now, is_online: true, created_at: Time.now, season_id: @aux_season.id, organizer_id: @aux_player.id })
  end

  let(:valid_attributes) do
    {
      round_number: 1,
      status: :pending,
      time_limit_minutes: 1,
      tournament_id: @dep_tournament.id
    }
  end

  describe "GET /api/tournament_rounds" do
    it "returns 200" do
      get "/api/tournament_rounds"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/tournament_rounds" do
    context "with valid params" do
      it "returns 201" do
        post "/api/tournament_rounds", params: { tournament_round: {
      round_number: 1,
      status: :pending,
      time_limit_minutes: 1,
      tournament_id: @dep_tournament.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/tournament_rounds/:id" do
    let!(:tournamentRound) { TournamentRound.create!(valid_attributes) }

    it "returns 200" do
      get "/api/tournament_rounds/#{tournamentRound.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/tournament_rounds/:id" do
    let!(:tournamentRound) { TournamentRound.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/tournament_rounds/#{tournamentRound.id}",
            params: { tournament_round: { round_number: 1 } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/tournament_rounds/:id" do
    let!(:tournamentRound) { TournamentRound.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/tournament_rounds/#{tournamentRound.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/tournament_rounds (rule: ended_after_started)" do
    it "create fails when ended after started violated" do
      # Round end time must be after start time
      post "/api/tournament_rounds", params: { tournament_round: {
        round_number: 1,
        tournament_id: 1,
        ended_at: Time.now - 1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
