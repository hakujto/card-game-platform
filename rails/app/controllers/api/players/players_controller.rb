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
          render json: { errors: @player.errors }, status: :unprocessable_content
        end
      end

      # GET /api/players/:id
      def show
        render json: @player
      end

      # PATCH/PUT /api/players/:id
      def update
        if @player.update(player_update_params)
          render json: @player
        else
          render json: { errors: @player.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/players/:id
      def destroy
        @player.destroy
        head :no_content
      end

      # POST /api/players/:id/promote
      def promote
        @player = Player.find(params[:id])
        result = @player.promote
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Player not found' }, status: :not_found
      end

      # POST /api/players/:id/demote
      def demote
        @player = Player.find(params[:id])
        result = @player.demote
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Player not found' }, status: :not_found
      end

      # POST /api/players/:id/win
      def record_win
        @player = Player.find(params[:id])
        @player.record_win
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Player not found' }, status: :not_found
      end

      # POST /api/players/:id/loss
      def record_loss
        @player = Player.find(params[:id])
        @player.record_loss
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Player not found' }, status: :not_found
      end

      # GET /api/players/:id/win-rate
      def win_rate
        @player = Player.find(params[:id])
        result = @player.win_rate
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Player not found' }, status: :not_found
      end

      # POST /api/players/:id/verify
      def verify
        @player = Player.find(params[:id])
        @player.verify
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Player not found' }, status: :not_found
      end

      # PATCH /api/players/:id/rating
      def update_rating
        @player = Player.find(params[:id])
        delta = params[:delta]
        @player.update_rating(delta)
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Player not found' }, status: :not_found
      end

      private

      def set_player
        @player = Player.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Player not found' }, status: :not_found
      end

      def player_params
        params.fetch(:player, params).permit(:display_name, :rank, :rating, :peak_rating, :bio, :country_code, :avatar_url, :preferred_format, :is_verified, :created_at, :last_active_at, :user_id)
      end

      def player_update_params
        params.fetch(:player, params).permit(:display_name, :rank, :rating, :peak_rating, :bio, :country_code, :avatar_url, :preferred_format, :is_verified, :created_at, :last_active_at, :user_id)
      end
    end
  end
end
