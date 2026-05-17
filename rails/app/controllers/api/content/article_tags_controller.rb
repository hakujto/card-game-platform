module Api
  module Content
    class ArticleTagsController < ApplicationController
      before_action :set_articleTag, only: [:show, :update, :destroy]

      # GET /api/article_tags
      def index
        @article_tags = ArticleTag.all
        render json: @article_tags
      end

      # POST /api/article_tags
      def create
        @articleTag = ArticleTag.new(article_tag_params)
        if @articleTag.save
          render json: @articleTag, status: :created
        else
          render json: { errors: @articleTag.errors }, status: :unprocessable_content
        end
      end

      # GET /api/article_tags/:id
      def show
        render json: @articleTag
      end

      # PATCH/PUT /api/article_tags/:id
      def update
        if @articleTag.update(article_tag_update_params)
          render json: @articleTag
        else
          render json: { errors: @articleTag.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/article_tags/:id
      def destroy
        @articleTag.destroy
        head :no_content
      end

      private

      def set_articleTag
        @articleTag = ArticleTag.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'ArticleTag not found' }, status: :not_found
      end

      def article_tag_params
        params.fetch(:article_tag, params).permit(:name, :slug)
      end

      def article_tag_update_params
        params.fetch(:article_tag, params).permit(:name, :slug)
      end
    end
  end
end
