require 'rails_helper'

RSpec.describe "Api::Content::Articles", type: :request do
  let(:valid_attributes) do
    {
        title: 'test',
        slug: 'test',
        body: 'test',
        view_count: 1,
        created_at: Time.now,
        updated_at: Time.now
    }
  end

  describe "GET /api/articles" do
    it "returns 200" do
      get "/api/articles"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/articles" do
    context "with valid params" do
      it "returns 201" do
        post "/api/articles", params: { article: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/articles/:id" do
    let!(:article) { Article.create!(valid_attributes) }

    it "returns 200" do
      get "/api/articles/#{article.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/articles/:id" do
    let!(:article) { Article.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/articles/#{article.id}",
            params: { article: { title: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/articles/:id" do
    let!(:article) { Article.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/articles/#{article.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
