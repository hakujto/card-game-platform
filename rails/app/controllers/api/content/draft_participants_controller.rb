module Api
  module Content
    class DraftParticipantsController < ApplicationController
      before_action :set_draftParticipant, only: [:show, :update, :destroy]

      # GET /api/draft_participants
      def index
        @draft_participants = DraftParticipant.all
        render json: @draft_participants
      end

      # POST /api/draft_participants
      def create
        @draftParticipant = DraftParticipant.new(draft_participant_params)
        if @draftParticipant.save
          render json: @draftParticipant, status: :created
        else
          render json: { errors: @draftParticipant.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/draft_participants/:id
      def show
        render json: @draftParticipant
      end

      # PATCH/PUT /api/draft_participants/:id
      def update
        if @draftParticipant.update(draft_participant_params)
          render json: @draftParticipant
        else
          render json: { errors: @draftParticipant.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/draft_participants/:id
      def destroy
        @draftParticipant.destroy
        head :no_content
      end

      private

      def set_draftParticipant
        @draftParticipant = DraftParticipant.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DraftParticipant not found' }, status: :not_found
      end

      def draft_participant_params
        params.permit(:seat_number, :joined_at, :session_id, :player_id, :drafted_cards_id)
      end
    end
  end
end
