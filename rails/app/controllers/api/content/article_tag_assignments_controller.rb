module Api
  module Content
    class ArticleTagAssignmentsController < ApplicationController
      before_action :set_articleTagAssignment, only: [:show, :destroy]

      # GET /api/article_tag_assignments
      def index
        @article_tag_assignments = ArticleTagAssignment.all
        render json: @article_tag_assignments
      end

      # POST /api/article_tag_assignments
      def create
        @articleTagAssignment = ArticleTagAssignment.new(article_tag_assignment_params)
        if @articleTagAssignment.save
          render json: @articleTagAssignment, status: :created
        else
          render json: { errors: @articleTagAssignment.errors }, status: :unprocessable_content
        end
      end

      # GET /api/article_tag_assignments/:id
      def show
        render json: @articleTagAssignment
      end

      # DELETE /api/article_tag_assignments/:id
      def destroy
        @articleTagAssignment.destroy
        head :no_content
      end

      private

      def set_articleTagAssignment
        @articleTagAssignment = ArticleTagAssignment.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'ArticleTagAssignment not found' }, status: :not_found
      end

      def article_tag_assignment_params
        params.fetch(:article_tag_assignment, params).permit(:article_id, :tag_id)
      end

      def article_tag_assignment_update_params
        params.fetch(:article_tag_assignment, params).permit(:article_id, :tag_id)
      end
    end
  end
end
