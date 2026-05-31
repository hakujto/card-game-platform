module Api
  module Players
    class PlayerAchievementsController < ApplicationController
      before_action :set_playerAchievement, only: [:show]

      # GET /api/player_achievements
      def index
        @player_achievements = PlayerAchievement.all
        render json: @player_achievements
      end

      # GET /api/player_achievements/:id
      def show
        render json: @playerAchievement
      end

      # PATCH /api/player_achievements/:id/progress
      def increment_progress
        @playerAchievement = PlayerAchievement.find(params[:id])
        amount = params[:amount]
        @playerAchievement.increment_progress(amount)
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'PlayerAchievement not found' }, status: :not_found
      end

      # POST /api/player_achievements/:id/complete
      def complete
        @playerAchievement = PlayerAchievement.find(params[:id])
        @playerAchievement.complete()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'PlayerAchievement not found' }, status: :not_found
      end

      private

      def set_playerAchievement
        @playerAchievement = PlayerAchievement.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'PlayerAchievement not found' }, status: :not_found
      end

      def player_achievement_params
        params.fetch(:player_achievement, params).permit(:earned_at, :progress, :is_completed, :player_id, :achievement_id)
      end

      def player_achievement_update_params
        params.fetch(:player_achievement, params).permit(:earned_at, :progress, :is_completed, :player_id, :achievement_id)
      end
    end
  end
end
