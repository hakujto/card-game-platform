module Api
  module Content
    class DraftSessionsController < ApplicationController
      before_action :set_draftSession, only: [:show, :update, :destroy]

      # GET /api/draft_sessions
      def index
        @draft_sessions = DraftSession.all
        render json: @draft_sessions
      end

      # POST /api/draft_sessions
      def create
        @draftSession = DraftSession.new(draft_session_params)
        if @draftSession.save
          render json: @draftSession, status: :created
        else
          render json: { errors: @draftSession.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/draft_sessions/:id
      def show
        render json: @draftSession
      end

      # PATCH/PUT /api/draft_sessions/:id
      def update
        if @draftSession.update(draft_session_params)
          render json: @draftSession
        else
          render json: { errors: @draftSession.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/draft_sessions/:id
      def destroy
        @draftSession.destroy
        head :no_content
      end

      private

      def set_draftSession
        @draftSession = DraftSession.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DraftSession not found' }, status: :not_found
      end

      def draft_session_params
        params.permit(:status, :draft_type, :seats, :created_at, :completed_at, :card_set_id, :participants_id)
      end
    end
  end
end
