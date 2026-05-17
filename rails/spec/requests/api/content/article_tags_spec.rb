require 'rails_helper'

RSpec.describe "Api::Content::ArticleTags", type: :request do
  let(:valid_attributes) do
    {
      name: 'test',
      slug: 'test'
    }
  end

  describe "GET /api/article_tags" do
    it "returns 200" do
      get "/api/article_tags"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/article_tags" do
    context "with valid params" do
      it "returns 201" do
        post "/api/article_tags", params: { article_tag: {
      name: 'test',
      slug: 'test'
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/article_tags/:id" do
    let!(:articleTag) { ArticleTag.create!(valid_attributes) }

    it "returns 200" do
      get "/api/article_tags/#{articleTag.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/article_tags/:id" do
    let!(:articleTag) { ArticleTag.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/article_tags/#{articleTag.id}",
            params: { article_tag: { name: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/article_tags/:id" do
    let!(:articleTag) { ArticleTag.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/article_tags/#{articleTag.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
