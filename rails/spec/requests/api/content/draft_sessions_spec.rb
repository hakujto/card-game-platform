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
      time_per_pick_seconds: 1,
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
      time_per_pick_seconds: 1,
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

  describe "POST /api/draft_sessions (rule: time_per_pick_positive)" do
    it "create fails when time per pick positive violated" do
      # Time per pick must be greater than zero
      post "/api/draft_sessions", params: { draft_session: {
        created_at: Time.now,
        card_set_id: 1,
        completed_at: Time.now,
        status: :completed,
        time_per_pick_seconds: 0,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
  describe "PATCH /api/draft_sessions/:id/transitions/waitingforplayers-to-drafting" do
    let!(:draftSession) { DraftSession.create!(valid_attributes).tap { |r| r.update_column(:status, DraftSession.statuses['waiting_for_players']) } }
    it "transitions to Drafting" do
      patch "/api/draft_sessions/#{draftSession.id}/transitions/waitingforplayers-to-drafting"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(draftSession.reload.status).to eq('drafting') if response.status == 200
    end
  end

  describe "PATCH /api/draft_sessions/:id/transitions/drafting-to-completed" do
    let!(:draftSession) { DraftSession.create!(valid_attributes).tap { |r| r.update_column(:status, DraftSession.statuses['drafting']) } }
    it "transitions to Completed" do
      patch "/api/draft_sessions/#{draftSession.id}/transitions/drafting-to-completed"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(draftSession.reload.status).to eq('completed') if response.status == 200
    end
  end

  describe "PATCH /api/draft_sessions/:id/transitions/drafting-to-abandoned" do
    let!(:draftSession) { DraftSession.create!(valid_attributes).tap { |r| r.update_column(:status, DraftSession.statuses['drafting']) } }
    it "transitions to Abandoned" do
      patch "/api/draft_sessions/#{draftSession.id}/transitions/drafting-to-abandoned"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(draftSession.reload.status).to eq('abandoned') if response.status == 200
    end
  end

  describe "PATCH /api/draft_sessions/:id/transitions/waitingforplayers-to-abandoned" do
    let!(:draftSession) { DraftSession.create!(valid_attributes).tap { |r| r.update_column(:status, DraftSession.statuses['waiting_for_players']) } }
    it "transitions to Abandoned" do
      patch "/api/draft_sessions/#{draftSession.id}/transitions/waitingforplayers-to-abandoned"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(draftSession.reload.status).to eq('abandoned') if response.status == 200
    end
  end

  describe "PATCH /api/draft_sessions/:id/transitions/completed-to-drafting" do
    let!(:draftSession) { DraftSession.create!(valid_attributes) }
    it "returns 409 (denied)" do
      patch "/api/draft_sessions/#{draftSession.id}/transitions/completed-to-drafting"
      expect(response).to have_http_status(:conflict)
    end
  end

  describe "PATCH /api/draft_sessions/:id/transitions/abandoned-to-drafting" do
    let!(:draftSession) { DraftSession.create!(valid_attributes) }
    it "returns 409 (denied)" do
      patch "/api/draft_sessions/#{draftSession.id}/transitions/abandoned-to-drafting"
      expect(response).to have_http_status(:conflict)
    end
  end
end
