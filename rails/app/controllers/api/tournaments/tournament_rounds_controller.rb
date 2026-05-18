module Api
  module Tournaments
    class TournamentRoundsController < ApplicationController
      before_action :set_tournamentRound, only: [:show, :update, :destroy]

      # GET /api/tournament_rounds
      def index
        @tournament_rounds = TournamentRound.all
        render json: @tournament_rounds
      end

      # POST /api/tournament_rounds
      def create
        @tournamentRound = TournamentRound.new(tournament_round_params)
        if @tournamentRound.save
          render json: @tournamentRound, status: :created
        else
          render json: { errors: @tournamentRound.errors }, status: :unprocessable_content
        end
      end

      # GET /api/tournament_rounds/:id
      def show
        render json: @tournamentRound
      end

      # PATCH/PUT /api/tournament_rounds/:id
      def update
        if @tournamentRound.update(tournament_round_update_params)
          render json: @tournamentRound
        else
          render json: { errors: @tournamentRound.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/tournament_rounds/:id
      def destroy
        @tournamentRound.destroy
        head :no_content
      end

      # POST /api/tournament_rounds/:id/start
      def start
        @tournamentRound = TournamentRound.find(params[:id])
        @tournamentRound.start()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TournamentRound not found' }, status: :not_found
      end

      # POST /api/tournament_rounds/:id/complete
      def complete
        @tournamentRound = TournamentRound.find(params[:id])
        @tournamentRound.complete()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TournamentRound not found' }, status: :not_found
      end

      # POST /api/tournament_rounds/:id/pairings
      def generate_pairings
        @tournamentRound = TournamentRound.find(params[:id])
        @tournamentRound.generate_pairings()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TournamentRound not found' }, status: :not_found
      end

      # GET /api/tournament_rounds/:id/time-expired
      def is_time_expired
        @tournamentRound = TournamentRound.find(params[:id])
        result = @tournamentRound.is_time_expired()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TournamentRound not found' }, status: :not_found
      end

      private

      def set_tournamentRound
        @tournamentRound = TournamentRound.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TournamentRound not found' }, status: :not_found
      end

      def tournament_round_params
        params.fetch(:tournament_round, params).permit(:round_number, :status, :started_at, :ended_at, :time_limit_minutes, :tournament_id)
      end

      def tournament_round_update_params
        params.fetch(:tournament_round, params).permit(:round_number, :status, :started_at, :ended_at, :time_limit_minutes, :tournament_id)
      end
    end
  end
end
