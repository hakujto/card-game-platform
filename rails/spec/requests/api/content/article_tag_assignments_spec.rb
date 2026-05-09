require 'rails_helper'

RSpec.describe "Api::Content::ArticleTagAssignments", type: :request do
  let(:valid_attributes) do
    {
        # add required fields here
    }
  end

  describe "GET /api/article_tag_assignments" do
    it "returns 200" do
      get "/api/article_tag_assignments"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/article_tag_assignments" do
    context "with valid params" do
      it "returns 201" do
        post "/api/article_tag_assignments", params: { article_tag_assignment: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/article_tag_assignments/:id" do
    let!(:articleTagAssignment) { ArticleTagAssignment.create!(valid_attributes) }

    it "returns 200" do
      get "/api/article_tag_assignments/#{articleTagAssignment.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/article_tag_assignments/:id" do
    let!(:articleTagAssignment) { ArticleTagAssignment.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/article_tag_assignments/#{articleTagAssignment.id}",
            params: { article_tag_assignment: {  } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/article_tag_assignments/:id" do
    let!(:articleTagAssignment) { ArticleTagAssignment.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/article_tag_assignments/#{articleTagAssignment.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
