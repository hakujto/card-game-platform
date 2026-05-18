module Api
  module Tournaments
    class MatchesController < ApplicationController
      before_action :set_match, only: [:show, :update, :destroy]

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

      # PATCH/PUT /api/matches/:id
      def update
        if @match.update(match_update_params)
          render json: @match
        else
          render json: { errors: @match.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/matches/:id
      def destroy
        @match.destroy
        head :no_content
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
