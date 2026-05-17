module Api
  module Tournaments
    class TournamentPrizesController < ApplicationController
      before_action :set_tournamentPrize, only: [:show, :update, :destroy]

      # GET /api/tournament_prizes
      def index
        @tournament_prizes = TournamentPrize.all
        render json: @tournament_prizes
      end

      # POST /api/tournament_prizes
      def create
        @tournamentPrize = TournamentPrize.new(tournament_prize_params)
        if @tournamentPrize.save
          render json: @tournamentPrize, status: :created
        else
          render json: { errors: @tournamentPrize.errors }, status: :unprocessable_content
        end
      end

      # GET /api/tournament_prizes/:id
      def show
        render json: @tournamentPrize
      end

      # PATCH/PUT /api/tournament_prizes/:id
      def update
        if @tournamentPrize.update(tournament_prize_update_params)
          render json: @tournamentPrize
        else
          render json: { errors: @tournamentPrize.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/tournament_prizes/:id
      def destroy
        @tournamentPrize.destroy
        head :no_content
      end

      private

      def set_tournamentPrize
        @tournamentPrize = TournamentPrize.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TournamentPrize not found' }, status: :not_found
      end

      def tournament_prize_params
        params.fetch(:tournament_prize, params).permit(:placement_from, :placement_to, :prize_type, :amount, :description, :packs_count, :season_points, :tournament_id)
      end

      def tournament_prize_update_params
        params.fetch(:tournament_prize, params).permit(:placement_from, :placement_to, :prize_type, :amount, :description, :packs_count, :season_points, :tournament_id)
      end
    end
  end
end
