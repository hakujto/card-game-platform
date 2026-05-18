module Api
  module Tournaments
    class GamesController < ApplicationController
      before_action :set_game, only: [:show, :update, :destroy]

      # GET /api/games
      def index
        @games = Game.all
        render json: @games
      end

      # POST /api/games
      def create
        @game = Game.new(game_params)
        if @game.save
          render json: @game, status: :created
        else
          render json: { errors: @game.errors }, status: :unprocessable_content
        end
      end

      # GET /api/games/:id
      def show
        render json: @game
      end

      # PATCH/PUT /api/games/:id
      def update
        if @game.update(game_update_params)
          render json: @game
        else
          render json: { errors: @game.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/games/:id
      def destroy
        @game.destroy
        head :no_content
      end

      # POST /api/games/:id/winner
      def record_winner
        @game = Game.find(params[:id])
        winner_side = params[:winner_side]
        @game.record_winner(winner_side)
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Game not found' }, status: :not_found
      end

      # GET /api/games/:id/duration
      def duration_minutes
        @game = Game.find(params[:id])
        result = @game.duration_minutes()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Game not found' }, status: :not_found
      end

      private

      def set_game
        @game = Game.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Game not found' }, status: :not_found
      end

      def game_params
        params.fetch(:game, params).permit(:game_number, :winner_side, :turns_played, :duration_seconds, :ended_by, :replay_url, :match_id, :winner_id)
      end

      def game_update_params
        params.fetch(:game, params).permit(:game_number, :winner_side, :turns_played, :duration_seconds, :ended_by, :replay_url, :match_id, :winner_id)
      end
    end
  end
end
