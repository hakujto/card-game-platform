require 'rails_helper'

RSpec.describe "Api::Content::DraftSessions", type: :request do
  let(:valid_attributes) do
    {
        seats: 1,
        created_at: Time.now
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
        post "/api/draft_sessions", params: { draft_session: valid_attributes }, as: :json
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
            params: { draft_session: { status: 'test' } },
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
end
