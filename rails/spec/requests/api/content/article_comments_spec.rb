require 'rails_helper'

RSpec.describe "Api::Content::ArticleComments", type: :request do
  let(:valid_attributes) do
    {
        body: 'test',
        is_hidden: true,
        created_at: Time.now
    }
  end

  describe "GET /api/article_comments" do
    it "returns 200" do
      get "/api/article_comments"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/article_comments" do
    context "with valid params" do
      it "returns 201" do
        post "/api/article_comments", params: { article_comment: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/article_comments/:id" do
    let!(:articleComment) { ArticleComment.create!(valid_attributes) }

    it "returns 200" do
      get "/api/article_comments/#{articleComment.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/article_comments/:id" do
    let!(:articleComment) { ArticleComment.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/article_comments/#{articleComment.id}",
            params: { article_comment: { body: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/article_comments/:id" do
    let!(:articleComment) { ArticleComment.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/article_comments/#{articleComment.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
