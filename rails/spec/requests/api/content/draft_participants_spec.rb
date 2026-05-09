require 'rails_helper'

RSpec.describe "Api::Content::DraftParticipants", type: :request do
  let(:valid_attributes) do
    {
        seat_number: 1,
        joined_at: Time.now
    }
  end

  describe "GET /api/draft_participants" do
    it "returns 200" do
      get "/api/draft_participants"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/draft_participants" do
    context "with valid params" do
      it "returns 201" do
        post "/api/draft_participants", params: { draft_participant: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/draft_participants/:id" do
    let!(:draftParticipant) { DraftParticipant.create!(valid_attributes) }

    it "returns 200" do
      get "/api/draft_participants/#{draftParticipant.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/draft_participants/:id" do
    let!(:draftParticipant) { DraftParticipant.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/draft_participants/#{draftParticipant.id}",
            params: { draft_participant: { seat_number: 1 } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/draft_participants/:id" do
    let!(:draftParticipant) { DraftParticipant.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/draft_participants/#{draftParticipant.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
