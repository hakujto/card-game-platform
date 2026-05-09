module Api
  module Players
    class PlayersController < ApplicationController
      before_action :set_player, only: [:show, :update, :destroy]

      # GET /api/players
      def index
        @players = Player.all
        render json: @players
      end

      # POST /api/players
      def create
        @player = Player.new(player_params)
        if @player.save
          render json: @player, status: :created
        else
          render json: { errors: @player.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/players/:id
      def show
        render json: @player
      end

      # PATCH/PUT /api/players/:id
      def update
        if @player.update(player_params)
          render json: @player
        else
          render json: { errors: @player.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/players/:id
      def destroy
        @player.destroy
        head :no_content
      end

      private

      def set_player
        @player = Player.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Player not found' }, status: :not_found
      end

      def player_params
        params.permit(:display_name, :rank, :rating, :peak_rating, :bio, :country_code, :avatar_url, :preferred_format, :is_verified, :created_at, :last_active_at, :user_id, :season_stats_id)
      end
    end
  end
end
