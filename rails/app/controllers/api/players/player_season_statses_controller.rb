module Api
  module Players
    class PlayerSeasonStatsesController < ApplicationController
      before_action :set_playerSeasonStats, only: [:show, :update, :destroy]

      # GET /api/player_season_statses
      def index
        @player_season_statses = PlayerSeasonStats.all
        render json: @player_season_statses
      end

      # POST /api/player_season_statses
      def create
        @playerSeasonStats = PlayerSeasonStats.new(player_season_stats_params)
        if @playerSeasonStats.save
          render json: @playerSeasonStats, status: :created
        else
          render json: { errors: @playerSeasonStats.errors }, status: :unprocessable_content
        end
      end

      # GET /api/player_season_statses/:id
      def show
        render json: @playerSeasonStats
      end

      # PATCH/PUT /api/player_season_statses/:id
      def update
        if @playerSeasonStats.update(player_season_stats_update_params)
          render json: @playerSeasonStats
        else
          render json: { errors: @playerSeasonStats.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/player_season_statses/:id
      def destroy
        @playerSeasonStats.destroy
        head :no_content
      end

      private

      def set_playerSeasonStats
        @playerSeasonStats = PlayerSeasonStats.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'PlayerSeasonStats not found' }, status: :not_found
      end

      def player_season_stats_params
        params.fetch(:player_season_stats, params).permit(:wins, :losses, :draws, :tournament_wins, :highest_rank, :season_points, :player_id, :season_id)
      end

      def player_season_stats_update_params
        params.fetch(:player_season_stats, params).permit(:wins, :losses, :draws, :tournament_wins, :highest_rank, :season_points, :player_id, :season_id)
      end
    end
  end
end
