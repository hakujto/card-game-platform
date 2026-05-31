module Api
  module Tournaments
    class MatchesController < ApplicationController
      before_action :set_match, only: [:show]

      # GET /api/matches
      def index
        @matches = Match.all
        render json: @matches
      end

      # POST /api/matches
      def create
        @match = Match.new(match_params)
        if @match.save
          render json: @match, status: :created
        else
          render json: { errors: @match.errors }, status: :unprocessable_content
        end
      end

      # GET /api/matches/:id
      def show
        render json: @match
      end

      # POST /api/matches/:id/record
      def record_result
        @match = Match.find(params[:id])
        p1_wins = params[:p1_wins]
        p2_wins = params[:p2_wins]
        @match.record_result(p1_wins, p2_wins)
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Match not found' }, status: :not_found
      end

      # POST /api/matches/:id/finalize
      def finalize_result
        @match = Match.find(params[:id])
        @match.finalize_result()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Match not found' }, status: :not_found
      end

      # GET /api/matches/:id/winner
      def determine_winner
        @match = Match.find(params[:id])
        result = @match.determine_winner()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Match not found' }, status: :not_found
      end

      # POST /api/matches/:id/concede
      def concede
        @match = Match.find(params[:id])
        player_id = params[:player_id]
        @match.concede(player_id)
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Match not found' }, status: :not_found
      end

      # POST /api/matches/:id/draw
      def draw
        @match = Match.find(params[:id])
        @match.draw()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Match not found' }, status: :not_found
      end
      # PATCH /api/:id/transitions/pending-to-active
      def transition_pending_to_active
        @match = Match.find(params[:id])
        @match.assert_transition!('active')
        @match.status = 'active'
        if @match.save
          render json: @match
        else
          render json: { errors: @match.errors }, status: :unprocessable_content
        end
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Match not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/active-to-completed
      def transition_active_to_completed
        @match = Match.find(params[:id])
        @match.assert_transition!('completed')
        @match.status = 'completed'
        @match.finalize_result  # @after
        if @match.save
          render json: @match
        else
          render json: { errors: @match.errors }, status: :unprocessable_content
        end
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Match not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/active-to-draw
      def transition_active_to_draw
        @match = Match.find(params[:id])
        @match.assert_transition!('draw')
        @match.status = 'draw'
        @match.draw  # @after
        if @match.save
          render json: @match
        else
          render json: { errors: @match.errors }, status: :unprocessable_content
        end
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Match not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/pending-to-bye
      def transition_pending_to_bye
        @match = Match.find(params[:id])
        @match.assert_transition!('b_y_e')
        @match.status = 'b_y_e'
        if @match.save
          render json: @match
        else
          render json: { errors: @match.errors }, status: :unprocessable_content
        end
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Match not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/completed-to-active
      def transition_completed_to_active
        render json: { error: 'Transition Completed -> Active is not allowed' }, status: :conflict
        return
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Match not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/draw-to-active
      def transition_draw_to_active
        render json: { error: 'Transition Draw -> Active is not allowed' }, status: :conflict
        return
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Match not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/bye-to-active
      def transition_bye_to_active
        render json: { error: 'Transition BYE -> Active is not allowed' }, status: :conflict
        return
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Match not found' }, status: :not_found
      end

      private

      def set_match
        @match = Match.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Match not found' }, status: :not_found
      end

      def match_params
        params.fetch(:match, params).permit(:table_number, :status, :player1_wins, :player2_wins, :started_at, :ended_at, :result_notes, :round_id, :player1_id, :player2_id)
      end

      def match_update_params
        params.fetch(:match, params).permit(:table_number, :status, :player1_wins, :player2_wins, :started_at, :ended_at, :result_notes, :round_id, :player1_id, :player2_id)
      end
    end
  end
end
