module Api
  module Players
    class AchievementsController < ApplicationController
      before_action :set_achievement, only: [:show, :update, :destroy]

      # GET /api/achievements
      def index
        @achievements = Achievement.all
        render json: @achievements
      end

      # POST /api/achievements
      def create
        @achievement = Achievement.new(achievement_params)
        if @achievement.save
          render json: @achievement, status: :created
        else
          render json: { errors: @achievement.errors }, status: :unprocessable_content
        end
      end

      # GET /api/achievements/:id
      def show
        render json: @achievement
      end

      # PATCH/PUT /api/achievements/:id
      def update
        if @achievement.update(achievement_update_params)
          render json: @achievement
        else
          render json: { errors: @achievement.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/achievements/:id
      def destroy
        @achievement.destroy
        head :no_content
      end

      private

      def set_achievement
        @achievement = Achievement.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Achievement not found' }, status: :not_found
      end

      def achievement_params
        params.fetch(:achievement, params).permit(:name, :description, :icon_url, :points, :rarity, :is_hidden)
      end

      def achievement_update_params
        params.fetch(:achievement, params).permit(:name, :description, :icon_url, :points, :rarity, :is_hidden)
      end
    end
  end
end
