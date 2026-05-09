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
          render json: { errors: @tournamentRound.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/tournament_rounds/:id
      def show
        render json: @tournamentRound
      end

      # PATCH/PUT /api/tournament_rounds/:id
      def update
        if @tournamentRound.update(tournament_round_params)
          render json: @tournamentRound
        else
          render json: { errors: @tournamentRound.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/tournament_rounds/:id
      def destroy
        @tournamentRound.destroy
        head :no_content
      end

      private

      def set_tournamentRound
        @tournamentRound = TournamentRound.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TournamentRound not found' }, status: :not_found
      end

      def tournament_round_params
        params.permit(:round_number, :status, :started_at, :ended_at, :time_limit_minutes, :tournament_id, :matches_id)
      end
    end
  end
end
