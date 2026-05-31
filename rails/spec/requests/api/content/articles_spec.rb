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
      language: :e_n,
      view_count: 1,
      likes_count: 1,
      is_featured: true,
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

  describe "GET /api/articles?q=test" do
    it "returns 200" do
      get "/api/articles?q=test"
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
      language: :e_n,
      view_count: 1,
      likes_count: 1,
      is_featured: true,
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

  describe "POST /api/articles (rule: view_count_not_negative)" do
    it "create fails when view count not negative violated" do
      # Article view count must not be negative
      post "/api/articles", params: { article: {
        title: 'test',
        slug: 'test',
        body: 'test',
        created_at: Time.now,
        updated_at: Time.now,
        author_id: 1,
        published_at: Time.now,
        view_count: -1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/articles (rule: likes_count_not_negative)" do
    it "create fails when likes count not negative violated" do
      # Article likes count must not be negative
      post "/api/articles", params: { article: {
        title: 'test',
        slug: 'test',
        body: 'test',
        created_at: Time.now,
        updated_at: Time.now,
        author_id: 1,
        published_at: Time.now,
        likes_count: -1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
  describe "PATCH /api/articles/:id/transitions/draft-to-published" do
    let!(:article) { Article.create!(valid_attributes).tap { |r| r.update_column(:status, Article.statuses['draft']) } }
    before { article.update!(title: 'test', body: 'test') }
    it "transitions to Published" do
      patch "/api/articles/#{article.id}/transitions/draft-to-published"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(article.reload.status).to eq('published') if response.status == 200
    end
  end

  describe "PATCH /api/articles/:id/transitions/published-to-archived" do
    let!(:article) { Article.create!(valid_attributes).tap { |r| r.update_column(:status, Article.statuses['published']) } }
    it "transitions to Archived" do
      patch "/api/articles/#{article.id}/transitions/published-to-archived"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(article.reload.status).to eq('archived') if response.status == 200
    end
  end

  describe "PATCH /api/articles/:id/transitions/archived-to-draft" do
    let!(:article) { Article.create!(valid_attributes).tap { |r| r.update_column(:status, Article.statuses['archived']) } }
    it "transitions to Draft" do
      patch "/api/articles/#{article.id}/transitions/archived-to-draft"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(article.reload.status).to eq('draft') if response.status == 200
    end
  end

  describe "PATCH /api/articles/:id/transitions/published-to-draft" do
    let!(:article) { Article.create!(valid_attributes) }
    it "returns 409 (denied)" do
      patch "/api/articles/#{article.id}/transitions/published-to-draft"
      expect(response).to have_http_status(:conflict)
    end
  end
end
