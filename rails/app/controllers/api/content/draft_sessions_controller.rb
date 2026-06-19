module Api
  module Content
    class DraftSessionsController < ApplicationController
      before_action :set_draftSession, only: [:show]

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
          render json: { errors: @draftSession.errors }, status: :unprocessable_content
        end
      end

      # GET /api/draft_sessions/:id
      def show
        render json: @draftSession
      end

      # POST /api/draft_sessions/:id/start
      def start
        @draftSession = DraftSession.find(params[:id])
        @draftSession.start()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DraftSession not found' }, status: :not_found
      end

      # POST /api/draft_sessions/:id/abandon
      def abandon
        @draftSession = DraftSession.find(params[:id])
        @draftSession.abandon()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DraftSession not found' }, status: :not_found
      end

      # POST /api/draft_sessions/:id/complete
      def complete
        @draftSession = DraftSession.find(params[:id])
        @draftSession.complete()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DraftSession not found' }, status: :not_found
      end

      # GET /api/draft_sessions/:id/full
      def is_full
        @draftSession = DraftSession.find(params[:id])
        result = @draftSession.is_full()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DraftSession not found' }, status: :not_found
      end
      # PATCH /api/:id/transitions/waitingforplayers-to-drafting
      def transition_waitingforplayers_to_drafting
        @draftSession = DraftSession.find(params[:id])
        @draftSession.assert_transition!('drafting')
        @draftSession.status = 'drafting'
        @draftSession.start  # @after
        if @draftSession.save
          render json: @draftSession
        else
          render json: { errors: @draftSession.errors }, status: :unprocessable_content
        end
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DraftSession not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/drafting-to-completed
      def transition_drafting_to_completed
        @draftSession = DraftSession.find(params[:id])
        @draftSession.assert_transition!('completed')
        @draftSession.status = 'completed'
        @draftSession.complete  # @after
        if @draftSession.save
          render json: @draftSession
        else
          render json: { errors: @draftSession.errors }, status: :unprocessable_content
        end
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DraftSession not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/drafting-to-abandoned
      def transition_drafting_to_abandoned
        unless current_user&.role.in?(["Admin", "Organizer"])
          render json: { error: 'Insufficient role for transition Drafting -> Abandoned' }, status: :forbidden
          return
        end
        @draftSession = DraftSession.find(params[:id])
        @draftSession.assert_transition!('abandoned')
        @draftSession.status = 'abandoned'
        @draftSession.abandon  # @after
        if @draftSession.save
          render json: @draftSession
        else
          render json: { errors: @draftSession.errors }, status: :unprocessable_content
        end
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DraftSession not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/waitingforplayers-to-abandoned
      def transition_waitingforplayers_to_abandoned
        unless current_user&.role.in?(["Admin", "Organizer"])
          render json: { error: 'Insufficient role for transition WaitingForPlayers -> Abandoned' }, status: :forbidden
          return
        end
        @draftSession = DraftSession.find(params[:id])
        @draftSession.assert_transition!('abandoned')
        @draftSession.status = 'abandoned'
        @draftSession.abandon  # @after
        if @draftSession.save
          render json: @draftSession
        else
          render json: { errors: @draftSession.errors }, status: :unprocessable_content
        end
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DraftSession not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/completed-to-drafting
      def transition_completed_to_drafting
        render json: { error: 'Transition Completed -> Drafting is not allowed' }, status: :conflict
        return
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DraftSession not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/abandoned-to-drafting
      def transition_abandoned_to_drafting
        render json: { error: 'Transition Abandoned -> Drafting is not allowed' }, status: :conflict
        return
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DraftSession not found' }, status: :not_found
      end

      private

      def set_draftSession
        @draftSession = DraftSession.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DraftSession not found' }, status: :not_found
      end

      def draft_session_params
        params.fetch(:draft_session, params).permit(:status, :draft_type, :seats, :time_per_pick_seconds, :created_at, :completed_at, :card_set_id)
      end

      def draft_session_update_params
        params.fetch(:draft_session, params).permit(:status, :draft_type, :seats, :time_per_pick_seconds, :created_at, :completed_at, :card_set_id)
      end
    end
  end
end
