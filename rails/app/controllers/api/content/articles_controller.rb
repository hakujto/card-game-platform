module Api
  module Content
    class ArticlesController < ApplicationController
      before_action :set_article, only: [:show, :update, :destroy]

      # GET /api/articles
      def index
        @articles = Article.all
        render json: @articles
      end

      # POST /api/articles
      def create
        @article = Article.new(article_params)
        if @article.save
          render json: @article, status: :created
        else
          render json: { errors: @article.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/articles/:id
      def show
        render json: @article
      end

      # PATCH/PUT /api/articles/:id
      def update
        if @article.update(article_params)
          render json: @article
        else
          render json: { errors: @article.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/articles/:id
      def destroy
        @article.destroy
        head :no_content
      end

      private

      def set_article
        @article = Article.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Article not found' }, status: :not_found
      end

      def article_params
        params.permit(:title, :slug, :body, :excerpt, :cover_image_url, :status, :article_type, :view_count, :published_at, :created_at, :updated_at, :author_id, :featured_deck_id, :comments_id)
      end
    end
  end
end
