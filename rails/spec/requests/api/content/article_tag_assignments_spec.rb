require 'rails_helper'

RSpec.describe "Api::Content::ArticleTagAssignments", type: :request do
  before(:each) do
    @aux_player = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @dep_article = Article.create!({ title: 'test', slug: 'test', body: 'test', status: :draft, article_type: :guide, view_count: 1, created_at: Time.now, updated_at: Time.now, author_id: @aux_player.id })
    @dep_tag = ArticleTag.create!({ name: 'test', slug: 'test' })
  end

  let(:valid_attributes) do
    {
      article_id: @dep_article.id,
      tag_id: @dep_tag.id
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
        post "/api/article_tag_assignments", params: { article_tag_assignment: {
      article_id: @dep_article.id,
      tag_id: @dep_tag.id
        } }, as: :json
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
