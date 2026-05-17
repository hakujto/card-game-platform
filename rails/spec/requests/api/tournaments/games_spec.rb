require 'rails_helper'

RSpec.describe "Api::Tournaments::Games", type: :request do
  before(:each) do
    @aux_season = Season.create!({ name: 'test', start_date: Date.today, end_date: Date.today + 1, format: :standard, is_active: true })
    @aux_player = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @aux_tournament = Tournament.create!({ name: 'test', format: :standard, tournament_type: :swiss, status: :draft, max_players: 2, entry_fee: '0.00', prize_pool: '0.00', start_time: Time.now, is_online: true, created_at: Time.now, season_id: @aux_season.id, organizer_id: @aux_player.id })
    @aux_tournament_round = TournamentRound.create!({ round_number: 1, status: :pending, time_limit_minutes: 1, tournament_id: @aux_tournament.id })
    @dep_match = Match.create!({ status: :pending, player1_wins: 1, player2_wins: 1, round_id: @aux_tournament_round.id, player1_id: @aux_player.id })
  end

  let(:valid_attributes) do
    {
      game_number: 1,
      match_id: @dep_match.id
    }
  end

  describe "GET /api/games" do
    it "returns 200" do
      get "/api/games"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/games" do
    context "with valid params" do
      it "returns 201" do
        post "/api/games", params: { game: {
      game_number: 1,
      match_id: @dep_match.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/games/:id" do
    let!(:game) { Game.create!(valid_attributes) }

    it "returns 200" do
      get "/api/games/#{game.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/games/:id" do
    let!(:game) { Game.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/games/#{game.id}",
            params: { game: { game_number: 1 } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/games/:id" do
    let!(:game) { Game.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/games/#{game.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/games (rule: game_number_range)" do
    it "create fails when game number range violated" do
      # Game number must be between 1 and 3 (best-of-3)
      post "/api/games", params: { game: {
        match_id: 1,
        turns_played: 1,
        duration_seconds: 1,
        game_number: 4,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/games (rule: turns_played_positive)" do
    it "create fails when turns played positive violated" do
      # Turns played must be greater than zero
      post "/api/games", params: { game: {
        game_number: 1,
        match_id: 1,
        turns_played: 0,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/games (rule: duration_positive)" do
    it "create fails when duration positive violated" do
      # Game duration must be greater than zero
      post "/api/games", params: { game: {
        game_number: 1,
        match_id: 1,
        duration_seconds: 0,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
