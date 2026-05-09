module Api
  module Content
    class ArticleTagAssignmentsController < ApplicationController
      before_action :set_articleTagAssignment, only: [:show, :update, :destroy]

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
          render json: { errors: @articleTagAssignment.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/article_tag_assignments/:id
      def show
        render json: @articleTagAssignment
      end

      # PATCH/PUT /api/article_tag_assignments/:id
      def update
        if @articleTagAssignment.update(article_tag_assignment_params)
          render json: @articleTagAssignment
        else
          render json: { errors: @articleTagAssignment.errors }, status: :unprocessable_entity
        end
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
        params.permit(:article_id, :tag_id)
      end
    end
  end
end
