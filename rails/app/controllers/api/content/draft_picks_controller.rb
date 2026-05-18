module Api
  module Content
    class DraftPicksController < ApplicationController
      before_action :set_draftPick, only: [:show, :update, :destroy]

      # GET /api/draft_picks
      def index
        @draft_picks = DraftPick.all
        render json: @draft_picks
      end

      # POST /api/draft_picks
      def create
        @draftPick = DraftPick.new(draft_pick_params)
        if @draftPick.save
          render json: @draftPick, status: :created
        else
          render json: { errors: @draftPick.errors }, status: :unprocessable_content
        end
      end

      # GET /api/draft_picks/:id
      def show
        render json: @draftPick
      end

      # PATCH/PUT /api/draft_picks/:id
      def update
        if @draftPick.update(draft_pick_update_params)
          render json: @draftPick
        else
          render json: { errors: @draftPick.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/draft_picks/:id
      def destroy
        @draftPick.destroy
        head :no_content
      end

      # GET /api/draft_picks/:id/first-pick
      def is_first_pick
        @draftPick = DraftPick.find(params[:id])
        result = @draftPick.is_first_pick()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DraftPick not found' }, status: :not_found
      end

      private

      def set_draftPick
        @draftPick = DraftPick.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DraftPick not found' }, status: :not_found
      end

      def draft_pick_params
        params.fetch(:draft_pick, params).permit(:pick_number, :pack_number, :picked_at, :participant_id, :card_id)
      end

      def draft_pick_update_params
        params.fetch(:draft_pick, params).permit(:pick_number, :pack_number, :picked_at, :participant_id, :card_id)
      end
    end
  end
end
