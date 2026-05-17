module Api
  module Cards
    class DeckTagAssignmentsController < ApplicationController
      before_action :set_deckTagAssignment, only: [:show, :update, :destroy]

      # GET /api/deck_tag_assignments
      def index
        @deck_tag_assignments = DeckTagAssignment.all
        render json: @deck_tag_assignments
      end

      # POST /api/deck_tag_assignments
      def create
        @deckTagAssignment = DeckTagAssignment.new(deck_tag_assignment_params)
        if @deckTagAssignment.save
          render json: @deckTagAssignment, status: :created
        else
          render json: { errors: @deckTagAssignment.errors }, status: :unprocessable_content
        end
      end

      # GET /api/deck_tag_assignments/:id
      def show
        render json: @deckTagAssignment
      end

      # PATCH/PUT /api/deck_tag_assignments/:id
      def update
        if @deckTagAssignment.update(deck_tag_assignment_update_params)
          render json: @deckTagAssignment
        else
          render json: { errors: @deckTagAssignment.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/deck_tag_assignments/:id
      def destroy
        @deckTagAssignment.destroy
        head :no_content
      end

      private

      def set_deckTagAssignment
        @deckTagAssignment = DeckTagAssignment.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DeckTagAssignment not found' }, status: :not_found
      end

      def deck_tag_assignment_params
        params.fetch(:deck_tag_assignment, params).permit(:deck_id, :tag_id)
      end

      def deck_tag_assignment_update_params
        params.fetch(:deck_tag_assignment, params).permit(:deck_id, :tag_id)
      end
    end
  end
end
