require 'rails_helper'

RSpec.describe "Api::Cards::DeckTagAssignments", type: :request do
  let(:valid_attributes) do
    {
        # add required fields here
    }
  end

  describe "GET /api/deck_tag_assignments" do
    it "returns 200" do
      get "/api/deck_tag_assignments"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/deck_tag_assignments" do
    context "with valid params" do
      it "returns 201" do
        post "/api/deck_tag_assignments", params: { deck_tag_assignment: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/deck_tag_assignments/:id" do
    let!(:deckTagAssignment) { DeckTagAssignment.create!(valid_attributes) }

    it "returns 200" do
      get "/api/deck_tag_assignments/#{deckTagAssignment.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/deck_tag_assignments/:id" do
    let!(:deckTagAssignment) { DeckTagAssignment.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/deck_tag_assignments/#{deckTagAssignment.id}",
            params: { deck_tag_assignment: {  } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/deck_tag_assignments/:id" do
    let!(:deckTagAssignment) { DeckTagAssignment.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/deck_tag_assignments/#{deckTagAssignment.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
