require 'rails_helper'

RSpec.describe "Api::Content::ArticleComments", type: :request do
  before(:each) do
    @aux_player = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @dep_article = Article.create!({ title: 'test', slug: 'test', body: 'test', status: :draft, article_type: :guide, view_count: 1, published_at: Time.now, created_at: Time.now, updated_at: Time.now, author_id: @aux_player.id })
  end

  let(:valid_attributes) do
    {
      body: 'test',
      is_hidden: true,
      created_at: Time.now,
      article_id: @dep_article.id,
      author_id: @aux_player.id
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
        post "/api/article_comments", params: { article_comment: {
      body: 'test',
      is_hidden: true,
      created_at: Time.now,
      article_id: @dep_article.id,
      author_id: @aux_player.id
        } }, as: :json
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
