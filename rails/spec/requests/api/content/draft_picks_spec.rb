require 'rails_helper'

RSpec.describe "Api::Content::DraftPicks", type: :request do
  let(:valid_attributes) do
    {
        pick_number: 1,
        pack_number: 1,
        picked_at: Time.now
    }
  end

  describe "GET /api/draft_picks" do
    it "returns 200" do
      get "/api/draft_picks"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/draft_picks" do
    context "with valid params" do
      it "returns 201" do
        post "/api/draft_picks", params: { draft_pick: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/draft_picks/:id" do
    let!(:draftPick) { DraftPick.create!(valid_attributes) }

    it "returns 200" do
      get "/api/draft_picks/#{draftPick.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/draft_picks/:id" do
    let!(:draftPick) { DraftPick.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/draft_picks/#{draftPick.id}",
            params: { draft_pick: { pick_number: 1 } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/draft_picks/:id" do
    let!(:draftPick) { DraftPick.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/draft_picks/#{draftPick.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
