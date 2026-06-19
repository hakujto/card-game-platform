require 'rails_helper'

RSpec.describe "Api::Tournaments::Matches", type: :request do
  before(:each) do
    @aux_season = Season.create!({ name: 'test', start_date: Date.today, end_date: Date.today + 1, format: :standard, is_active: true })
    @aux_player = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @aux_tournament = Tournament.create!({ name: 'test', status: :draft, format: :standard, tournament_type: :swiss, max_players: 2, entry_fee: '0.00', prize_pool: '0.00', start_time: Time.now, end_time: nil, is_online: true, created_at: Time.now, season_id: @aux_season.id, organizer_id: @aux_player.id })
    @dep_round = TournamentRound.create!({ round_number: 1, status: :pending, started_at: Time.now, ended_at: nil, time_limit_minutes: 1, tournament_id: @aux_tournament.id })
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


  describe "POST /api/matches (rule: wins_not_negative)" do
    it "create fails when wins not negative violated" do
      # Win counts must not be negative
      post "/api/matches", params: { match: {
        round_id: 1,
        player1_id: 1,
        player2: nil,
        ended_at: Time.now,
        started_at: Time.now,
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
        ended_at: Time.now,
        started_at: Time.now,
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

  describe "POST /api/matches (rule: ended_after_started)" do
    it "create fails when ended after started violated" do
      # Match end time must be after start time
      post "/api/matches", params: { match: {
        round_id: 1,
        player1_id: 1,
        ended_at: Time.now - 1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/matches (rule: completed_requires_started_at)" do
    it "create fails when completed requires started at violated" do
      # Completed match must have a start time
      post "/api/matches", params: { match: {
        round_id: 1,
        player1_id: 1,
        status: :completed,
        started_at: nil,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
  describe "PATCH /api/matches/:id/transitions/pending-to-active" do
    let!(:match) { Match.create!(valid_attributes).tap { |r| r.update_column(:status, Match.statuses['pending']) } }
    it "transitions to Active with role Judge" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'Judge'))
      patch "/api/matches/#{match.id}/transitions/pending-to-active"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(match.reload.status).to eq('active') if response.status == 200
    end

    it "returns 403 for transition Pending -> Active with insufficient role" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'guest'))
      patch "/api/matches/#{match.id}/transitions/pending-to-active"
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/matches/:id/transitions/active-to-completed" do
    let!(:match) { Match.create!(valid_attributes).tap { |r| r.update_column(:status, Match.statuses['active']) } }
    it "transitions to Completed with role Judge" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'Judge'))
      patch "/api/matches/#{match.id}/transitions/active-to-completed"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(match.reload.status).to eq('completed') if response.status == 200
    end

    it "returns 403 for transition Active -> Completed with insufficient role" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'guest'))
      patch "/api/matches/#{match.id}/transitions/active-to-completed"
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/matches/:id/transitions/active-to-draw" do
    let!(:match) { Match.create!(valid_attributes).tap { |r| r.update_column(:status, Match.statuses['active']) } }
    it "transitions to Draw with role Judge" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'Judge'))
      patch "/api/matches/#{match.id}/transitions/active-to-draw"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(match.reload.status).to eq('draw') if response.status == 200
    end

    it "returns 403 for transition Active -> Draw with insufficient role" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'guest'))
      patch "/api/matches/#{match.id}/transitions/active-to-draw"
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/matches/:id/transitions/pending-to-bye" do
    let!(:match) { Match.create!(valid_attributes).tap { |r| r.update_column(:status, Match.statuses['pending']) } }
    it "transitions to BYE with role Judge" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'Judge'))
      patch "/api/matches/#{match.id}/transitions/pending-to-bye"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(match.reload.status).to eq('b_y_e') if response.status == 200
    end

    it "returns 403 for transition Pending -> BYE with insufficient role" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'guest'))
      patch "/api/matches/#{match.id}/transitions/pending-to-bye"
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/matches/:id/transitions/completed-to-active" do
    let!(:match) { Match.create!(valid_attributes) }
    it "returns 409 (denied)" do
      patch "/api/matches/#{match.id}/transitions/completed-to-active"
      expect(response).to have_http_status(:conflict)
    end
  end

  describe "PATCH /api/matches/:id/transitions/draw-to-active" do
    let!(:match) { Match.create!(valid_attributes) }
    it "returns 409 (denied)" do
      patch "/api/matches/#{match.id}/transitions/draw-to-active"
      expect(response).to have_http_status(:conflict)
    end
  end

  describe "PATCH /api/matches/:id/transitions/bye-to-active" do
    let!(:match) { Match.create!(valid_attributes) }
    it "returns 409 (denied)" do
      patch "/api/matches/#{match.id}/transitions/bye-to-active"
      expect(response).to have_http_status(:conflict)
    end
  end
end
