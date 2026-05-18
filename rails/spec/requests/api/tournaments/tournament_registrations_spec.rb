require 'rails_helper'

RSpec.describe "Api::Tournaments::TournamentRegistrations", type: :request do
  before(:each) do
    @aux_season = Season.create!({ name: 'test', start_date: Date.today, end_date: Date.today + 1, format: :standard, is_active: true })
    @aux_player = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @dep_tournament = Tournament.create!({ name: 'test', format: :standard, tournament_type: :swiss, status: :draft, max_players: 2, entry_fee: '0.00', prize_pool: '0.00', start_time: Time.now, end_time: nil, is_online: true, created_at: Time.now, season_id: @aux_season.id, organizer_id: @aux_player.id })
    @dep_deck = Deck.create!({ name: 'test', format: :standard, is_public: true, is_tournament_legal: false, wins: 1, losses: 1, draws: 1, created_at: Time.now, updated_at: Time.now, player_id: @aux_player.id })
  end

  let(:valid_attributes) do
    {
      status: :registered,
      points_earned: 1,
      registered_at: Time.now,
      tournament_id: @dep_tournament.id,
      player_id: @aux_player.id,
      deck_id: @dep_deck.id
    }
  end

  describe "GET /api/tournament_registrations" do
    it "returns 200" do
      get "/api/tournament_registrations"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/tournament_registrations" do
    context "with valid params" do
      it "returns 201" do
        post "/api/tournament_registrations", params: { tournament_registration: {
      status: :registered,
      points_earned: 1,
      registered_at: Time.now,
      tournament_id: @dep_tournament.id,
      player_id: @aux_player.id,
      deck_id: @dep_deck.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/tournament_registrations/:id" do
    let!(:tournamentRegistration) { TournamentRegistration.create!(valid_attributes) }

    it "returns 200" do
      get "/api/tournament_registrations/#{tournamentRegistration.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/tournament_registrations/:id" do
    let!(:tournamentRegistration) { TournamentRegistration.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/tournament_registrations/#{tournamentRegistration.id}",
            params: { tournament_registration: { status: :registered } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/tournament_registrations/:id" do
    let!(:tournamentRegistration) { TournamentRegistration.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/tournament_registrations/#{tournamentRegistration.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/tournament_registrations (rule: points_earned_not_negative)" do
    it "create fails when points earned not negative violated" do
      # Points earned must not be negative
      post "/api/tournament_registrations", params: { tournament_registration: {
        registered_at: Time.now,
        tournament_id: 1,
        player_id: 1,
        deck_id: 1,
        final_standing: 1,
        seed: 1,
        points_earned: -1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/tournament_registrations (rule: final_standing_positive)" do
    it "create fails when final standing positive violated" do
      # Final standing must be greater than zero
      post "/api/tournament_registrations", params: { tournament_registration: {
        registered_at: Time.now,
        tournament_id: 1,
        player_id: 1,
        deck_id: 1,
        final_standing: 0,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/tournament_registrations (rule: seed_positive)" do
    it "create fails when seed positive violated" do
      # Seed must be greater than zero
      post "/api/tournament_registrations", params: { tournament_registration: {
        registered_at: Time.now,
        tournament_id: 1,
        player_id: 1,
        deck_id: 1,
        seed: 0,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
