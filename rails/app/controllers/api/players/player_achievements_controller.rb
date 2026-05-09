module Api
  module Players
    class PlayerAchievementsController < ApplicationController
      before_action :set_playerAchievement, only: [:show, :update, :destroy]

      # GET /api/player_achievements
      def index
        @player_achievements = PlayerAchievement.all
        render json: @player_achievements
      end

      # POST /api/player_achievements
      def create
        @playerAchievement = PlayerAchievement.new(player_achievement_params)
        if @playerAchievement.save
          render json: @playerAchievement, status: :created
        else
          render json: { errors: @playerAchievement.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/player_achievements/:id
      def show
        render json: @playerAchievement
      end

      # PATCH/PUT /api/player_achievements/:id
      def update
        if @playerAchievement.update(player_achievement_params)
          render json: @playerAchievement
        else
          render json: { errors: @playerAchievement.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/player_achievements/:id
      def destroy
        @playerAchievement.destroy
        head :no_content
      end

      private

      def set_playerAchievement
        @playerAchievement = PlayerAchievement.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'PlayerAchievement not found' }, status: :not_found
      end

      def player_achievement_params
        params.permit(:earned_at, :progress, :is_completed, :player_id, :achievement_id)
      end
    end
  end
end
