require 'rails_helper'

RSpec.describe "Api::Tournaments::TournamentPrizes", type: :request do
  before(:each) do
    @aux_season = Season.create!({ name: 'test', start_date: Date.today, end_date: Date.today + 1, format: :standard, is_active: true })
    @aux_player = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @dep_tournament = Tournament.create!({ name: 'test', format: :standard, tournament_type: :swiss, status: :draft, max_players: 2, entry_fee: '0.00', prize_pool: '0.00', start_time: Time.now, is_online: true, created_at: Time.now, season_id: @aux_season.id, organizer_id: @aux_player.id })
  end

  let(:valid_attributes) do
    {
      placement_from: 1,
      placement_to: 1,
      prize_type: :currency,
      amount: '0.00',
      season_points: 1,
      tournament_id: @dep_tournament.id
    }
  end

  describe "GET /api/tournament_prizes" do
    it "returns 200" do
      get "/api/tournament_prizes"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/tournament_prizes" do
    context "with valid params" do
      it "returns 201" do
        post "/api/tournament_prizes", params: { tournament_prize: {
      placement_from: 1,
      placement_to: 1,
      prize_type: :currency,
      amount: '0.00',
      season_points: 1,
      tournament_id: @dep_tournament.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/tournament_prizes/:id" do
    let!(:tournamentPrize) { TournamentPrize.create!(valid_attributes) }

    it "returns 200" do
      get "/api/tournament_prizes/#{tournamentPrize.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/tournament_prizes/:id" do
    let!(:tournamentPrize) { TournamentPrize.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/tournament_prizes/#{tournamentPrize.id}",
            params: { tournament_prize: { prize_type: :currency } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/tournament_prizes/:id" do
    let!(:tournamentPrize) { TournamentPrize.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/tournament_prizes/#{tournamentPrize.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/tournament_prizes (rule: placement_from_positive)" do
    it "create fails when placement from positive violated" do
      # placement_from must be greater than zero
      post "/api/tournament_prizes", params: { tournament_prize: {
        placement_to: 1,
        prize_type: :currency,
        tournament_id: 1,
        placement_from: 0,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/tournament_prizes (rule: amount_not_negative)" do
    it "create fails when amount not negative violated" do
      # Prize amount must not be negative
      post "/api/tournament_prizes", params: { tournament_prize: {
        placement_from: 1,
        placement_to: 1,
        prize_type: :currency,
        tournament_id: 1,
        amount: -1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
