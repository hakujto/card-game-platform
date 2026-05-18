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
          render json: { errors: @draftParticipant.errors }, status: :unprocessable_content
        end
      end

      # GET /api/draft_participants/:id
      def show
        render json: @draftParticipant
      end

      # PATCH/PUT /api/draft_participants/:id
      def update
        if @draftParticipant.update(draft_participant_update_params)
          render json: @draftParticipant
        else
          render json: { errors: @draftParticipant.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/draft_participants/:id
      def destroy
        @draftParticipant.destroy
        head :no_content
      end

      # POST /api/draft_participants/:id/pick
      def pick_card
        @draftParticipant = DraftParticipant.find(params[:id])
        card_id = params[:card_id]
        pack_number = params[:pack_number]
        @draftParticipant.pick_card(card_id, pack_number)
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DraftParticipant not found' }, status: :not_found
      end

      # GET /api/draft_participants/:id/card-count
      def drafted_card_count
        @draftParticipant = DraftParticipant.find(params[:id])
        result = @draftParticipant.drafted_card_count()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DraftParticipant not found' }, status: :not_found
      end

      private

      def set_draftParticipant
        @draftParticipant = DraftParticipant.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DraftParticipant not found' }, status: :not_found
      end

      def draft_participant_params
        params.fetch(:draft_participant, params).permit(:seat_number, :joined_at, :session_id, :player_id)
      end

      def draft_participant_update_params
        params.fetch(:draft_participant, params).permit(:seat_number, :joined_at, :session_id, :player_id)
      end
    end
  end
end
