require 'rails_helper'

RSpec.describe "Api::Content::Articles", type: :request do
  before(:each) do
    @dep_author = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
  end

  let(:valid_attributes) do
    {
      title: 'test',
      slug: 'test',
      body: 'test',
      status: :draft,
      article_type: :guide,
      view_count: 1,
      created_at: Time.now,
      updated_at: Time.now,
      author_id: @dep_author.id
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
        post "/api/articles", params: { article: {
      title: 'test',
      slug: 'test',
      body: 'test',
      status: :draft,
      article_type: :guide,
      view_count: 1,
      created_at: Time.now,
      updated_at: Time.now,
      author_id: @dep_author.id
        } }, as: :json
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

  describe "POST /api/articles (rule: published_requires_published_at)" do
    it "create fails when published requires published at violated" do
      # Published article must have a published_at timestamp
      post "/api/articles", params: { article: {
        title: 'test',
        slug: 'test',
        body: 'test',
        created_at: Time.now,
        updated_at: Time.now,
        author_id: 1,
        status: :published,
        published_at: nil,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
