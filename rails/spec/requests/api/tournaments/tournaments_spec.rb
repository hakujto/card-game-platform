require 'rails_helper'

RSpec.describe "Api::Tournaments::Tournaments", type: :request do
  before(:each) do
    @dep_season = Season.create!({ name: 'test', start_date: Date.today, end_date: Date.today + 1, format: :standard, is_active: true })
    @dep_organizer = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
  end

  let(:valid_attributes) do
    {
      name: 'test',
      format: :standard,
      tournament_type: :swiss,
      status: :draft,
      max_players: 2,
      entry_fee: '0.00',
      prize_pool: '0.00',
      start_time: Time.now,
      is_online: true,
      created_at: Time.now,
      season_id: @dep_season.id,
      organizer_id: @dep_organizer.id
    }
  end

  describe "GET /api/tournaments" do
    it "returns 200" do
      get "/api/tournaments"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/tournaments" do
    context "with valid params" do
      it "returns 201" do
        post "/api/tournaments", params: { tournament: {
      name: 'test',
      format: :standard,
      tournament_type: :swiss,
      status: :draft,
      max_players: 2,
      entry_fee: '0.00',
      prize_pool: '0.00',
      start_time: Time.now,
      is_online: true,
      created_at: Time.now,
      season_id: @dep_season.id,
      organizer_id: @dep_organizer.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/tournaments/:id" do
    let!(:tournament) { Tournament.create!(valid_attributes) }

    it "returns 200" do
      get "/api/tournaments/#{tournament.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/tournaments/:id" do
    let!(:tournament) { Tournament.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/tournaments/#{tournament.id}",
            params: { tournament: { name: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/tournaments/:id" do
    let!(:tournament) { Tournament.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/tournaments/#{tournament.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/tournaments (rule: max_players_positive)" do
    it "create fails when max players positive violated" do
      # Tournament must allow between 2 and 512 players
      post "/api/tournaments", params: { tournament: {
        name: 'test',
        start_time: Time.now,
        created_at: Time.now,
        season_id: 1,
        organizer_id: 1,
        end_time: Time.now,
        max_players: 513,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/tournaments (rule: entry_fee_not_negative)" do
    it "create fails when entry fee not negative violated" do
      # Entry fee must not be negative
      post "/api/tournaments", params: { tournament: {
        name: 'test',
        max_players: 1,
        start_time: Time.now,
        created_at: Time.now,
        season_id: 1,
        organizer_id: 1,
        end_time: Time.now,
        entry_fee: -1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/tournaments (rule: prize_pool_not_negative)" do
    it "create fails when prize pool not negative violated" do
      # Prize pool must not be negative
      post "/api/tournaments", params: { tournament: {
        name: 'test',
        max_players: 1,
        start_time: Time.now,
        created_at: Time.now,
        season_id: 1,
        organizer_id: 1,
        end_time: Time.now,
        prize_pool: -1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/tournaments (rule: end_time_after_start)" do
    it "create fails when end time after start violated" do
      # End time must be after start time
      post "/api/tournaments", params: { tournament: {
        name: 'test',
        max_players: 1,
        start_time: Time.now,
        created_at: Time.now,
        season_id: 1,
        organizer_id: 1,
        end_time: Time.now - 1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
