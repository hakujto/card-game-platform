module Api
  module Content
    class ArticleCommentsController < ApplicationController
      before_action :set_articleComment, only: [:show, :update, :destroy]

      # GET /api/article_comments
      def index
        @article_comments = ArticleComment.all
        render json: @article_comments
      end

      # POST /api/article_comments
      def create
        @articleComment = ArticleComment.new(article_comment_params)
        if @articleComment.save
          render json: @articleComment, status: :created
        else
          render json: { errors: @articleComment.errors }, status: :unprocessable_content
        end
      end

      # GET /api/article_comments/:id
      def show
        render json: @articleComment
      end

      # PATCH/PUT /api/article_comments/:id
      def update
        if @articleComment.update(article_comment_update_params)
          render json: @articleComment
        else
          render json: { errors: @articleComment.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/article_comments/:id
      def destroy
        @articleComment.destroy
        head :no_content
      end

      # POST /api/article_comments/:id/hide
      def hide
        @articleComment = ArticleComment.find(params[:id])
        @articleComment.hide
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'ArticleComment not found' }, status: :not_found
      end

      # POST /api/article_comments/:id/unhide
      def unhide
        @articleComment = ArticleComment.find(params[:id])
        @articleComment.unhide
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'ArticleComment not found' }, status: :not_found
      end

      private

      def set_articleComment
        @articleComment = ArticleComment.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'ArticleComment not found' }, status: :not_found
      end

      def article_comment_params
        params.fetch(:article_comment, params).permit(:body, :is_hidden, :created_at, :article_id, :author_id, :parent_comment_id)
      end

      def article_comment_update_params
        params.fetch(:article_comment, params).permit(:body, :is_hidden, :created_at, :article_id, :author_id, :parent_comment_id)
      end
    end
  end
end
