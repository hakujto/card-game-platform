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
          render json: { errors: @game.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/games/:id
      def show
        render json: @game
      end

      # PATCH/PUT /api/games/:id
      def update
        if @game.update(game_params)
          render json: @game
        else
          render json: { errors: @game.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/games/:id
      def destroy
        @game.destroy
        head :no_content
      end

      private

      def set_game
        @game = Game.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Game not found' }, status: :not_found
      end

      def game_params
        params.permit(:game_number, :winner_side, :turns_played, :duration_seconds, :ended_by, :replay_url, :match_id, :winner_id)
      end
    end
  end
end
