require 'rails_helper'

RSpec.describe "Api::Content::DraftSessions", type: :request do
  before(:each) do
    @dep_card_set = CardSet.create!({ name: 'test', code: 'test', release_date: Date.today, rotation_date: nil, set_type: :core, total_cards: 1, is_rotated: false })
  end

  let(:valid_attributes) do
    {
      status: :completed,
      draft_type: :booster,
      seats: 2,
      created_at: Time.now,
      card_set_id: @dep_card_set.id
    }
  end

  describe "GET /api/draft_sessions" do
    it "returns 200" do
      get "/api/draft_sessions"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/draft_sessions" do
    context "with valid params" do
      it "returns 201" do
        post "/api/draft_sessions", params: { draft_session: {
      status: :completed,
      draft_type: :booster,
      seats: 2,
      created_at: Time.now,
      card_set_id: @dep_card_set.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/draft_sessions/:id" do
    let!(:draftSession) { DraftSession.create!(valid_attributes) }

    it "returns 200" do
      get "/api/draft_sessions/#{draftSession.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/draft_sessions/:id" do
    let!(:draftSession) { DraftSession.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/draft_sessions/#{draftSession.id}",
            params: { draft_session: { draft_type: :booster } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/draft_sessions/:id" do
    let!(:draftSession) { DraftSession.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/draft_sessions/#{draftSession.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/draft_sessions (rule: seats_range)" do
    it "create fails when seats range violated" do
      # Draft session must have between 2 and 16 seats
      post "/api/draft_sessions", params: { draft_session: {
        created_at: Time.now,
        card_set_id: 1,
        completed_at: Time.now,
        status: :completed,
        seats: 17,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/draft_sessions (rule: completed_at_requires_completed_status)" do
    it "create fails when completed at requires completed status violated" do
      # completed_at can only be set when draft status is Completed
      post "/api/draft_sessions", params: { draft_session: {
        created_at: Time.now,
        card_set_id: 1,
        completed_at: Time.now,
        status: :waiting_for_players,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
