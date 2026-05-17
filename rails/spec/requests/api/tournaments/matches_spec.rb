require 'rails_helper'

RSpec.describe "Api::Tournaments::Matches", type: :request do
  before(:each) do
    @aux_season = Season.create!({ name: 'test', start_date: Date.today, end_date: Date.today + 1, format: :standard, is_active: true })
    @aux_player = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @aux_tournament = Tournament.create!({ name: 'test', format: :standard, tournament_type: :swiss, status: :draft, max_players: 2, entry_fee: '0.00', prize_pool: '0.00', start_time: Time.now, is_online: true, created_at: Time.now, season_id: @aux_season.id, organizer_id: @aux_player.id })
    @dep_round = TournamentRound.create!({ round_number: 1, status: :pending, time_limit_minutes: 1, tournament_id: @aux_tournament.id })
  end

  let(:valid_attributes) do
    {
      status: :pending,
      player1_wins: 1,
      player2_wins: 1,
      round_id: @dep_round.id,
      player1_id: @aux_player.id
    }
  end

  describe "GET /api/matches" do
    it "returns 200" do
      get "/api/matches"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/matches" do
    context "with valid params" do
      it "returns 201" do
        post "/api/matches", params: { match: {
      status: :pending,
      player1_wins: 1,
      player2_wins: 1,
      round_id: @dep_round.id,
      player1_id: @aux_player.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/matches/:id" do
    let!(:match) { Match.create!(valid_attributes) }

    it "returns 200" do
      get "/api/matches/#{match.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/matches/:id" do
    let!(:match) { Match.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/matches/#{match.id}",
            params: { match: { table_number: 1 } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/matches/:id" do
    let!(:match) { Match.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/matches/#{match.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/matches (rule: wins_not_negative)" do
    it "create fails when wins not negative violated" do
      # Win counts must not be negative
      post "/api/matches", params: { match: {
        round_id: 1,
        player1_id: 1,
        player2: nil,
        player1_wins: -1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/matches (rule: max_three_games)" do
    it "create fails when max three games violated" do
      # Win counts cannot exceed 2 in a best-of-3 match
      post "/api/matches", params: { match: {
        round_id: 1,
        player1_id: 1,
        player2: nil,
        player1_wins: 3,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/matches (rule: bye_has_no_player2)" do
    it "create fails when bye has no player2 violated" do
      # BYE match must not have a second player
      post "/api/matches", params: { match: {
        round_id: 1,
        player1_id: 1,
        status: :b_y_e,
        player2_id: 1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
