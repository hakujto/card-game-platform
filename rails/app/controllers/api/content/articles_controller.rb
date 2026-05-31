module Api
  module Content
    class ArticlesController < ApplicationController
      before_action :set_article, only: [:show, :update]

      # GET /api/articles?q=...
      def index
        q = params[:q]
        @articles = q.present? ? Article.where(Article.arel_table[:title].matches("%#{q}%").or(Article.arel_table[:excerpt].matches("%#{q}%"))) : Article.all
        render json: @articles
      end

      # POST /api/articles
      def create
        @article = Article.new(article_params)
        if @article.save
          render json: @article, status: :created
        else
          render json: { errors: @article.errors }, status: :unprocessable_content
        end
      end

      # GET /api/articles/:id
      def show
        render json: @article
      end

      # PATCH/PUT /api/articles/:id
      def update
        if @article.update(article_update_params)
          render json: @article
        else
          render json: { errors: @article.errors }, status: :unprocessable_content
        end
      end

      # POST /api/articles/:id/publish
      def publish
        @article = Article.find(params[:id])
        @article.publish()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Article not found' }, status: :not_found
      end

      # POST /api/articles/:id/archive
      def archive
        @article = Article.find(params[:id])
        @article.archive()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Article not found' }, status: :not_found
      end

      # POST /api/articles/:id/view
      def increment_view
        @article = Article.find(params[:id])
        @article.increment_view()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Article not found' }, status: :not_found
      end

      # POST /api/articles/:id/like
      def like
        @article = Article.find(params[:id])
        @article.like()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Article not found' }, status: :not_found
      end

      # DELETE /api/articles/:id/like
      def unlike
        @article = Article.find(params[:id])
        @article.unlike()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Article not found' }, status: :not_found
      end

      # GET /api/articles/:id/reading-time
      def reading_time_minutes
        @article = Article.find(params[:id])
        result = @article.reading_time_minutes()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Article not found' }, status: :not_found
      end
      # PATCH /api/:id/transitions/draft-to-published
      def transition_draft_to_published
        @article = Article.find(params[:id])
        @article.assert_transition!('published')
        if @article.title.nil?
          render json: { error: 'title is required for Draft -> Published' }, status: :unprocessable_content
          return
        end
        if @article.body.nil?
          render json: { error: 'body is required for Draft -> Published' }, status: :unprocessable_content
          return
        end
        @article.status = 'published'
        @article.publish  # @after
        if @article.save
          render json: @article
        else
          render json: { errors: @article.errors }, status: :unprocessable_content
        end
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Article not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/published-to-archived
      def transition_published_to_archived
        @article = Article.find(params[:id])
        @article.assert_transition!('archived')
        @article.status = 'archived'
        @article.archive  # @after
        if @article.save
          render json: @article
        else
          render json: { errors: @article.errors }, status: :unprocessable_content
        end
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Article not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/archived-to-draft
      def transition_archived_to_draft
        @article = Article.find(params[:id])
        @article.assert_transition!('draft')
        @article.status = 'draft'
        if @article.save
          render json: @article
        else
          render json: { errors: @article.errors }, status: :unprocessable_content
        end
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Article not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/published-to-draft
      def transition_published_to_draft
        render json: { error: 'Transition Published -> Draft is not allowed' }, status: :conflict
        return
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Article not found' }, status: :not_found
      end

      private

      def set_article
        @article = Article.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Article not found' }, status: :not_found
      end

      def article_params
        params.fetch(:article, params).permit(:title, :slug, :body, :excerpt, :cover_image_url, :status, :article_type, :language, :view_count, :likes_count, :is_featured, :published_at, :created_at, :updated_at, :author_id, :featured_deck_id)
      end

      def article_update_params
        params.fetch(:article, params).permit(:title, :slug, :body, :excerpt, :cover_image_url, :status, :article_type, :language, :view_count, :likes_count, :is_featured, :published_at, :created_at, :updated_at, :author_id, :featured_deck_id)
      end
    end
  end
end
