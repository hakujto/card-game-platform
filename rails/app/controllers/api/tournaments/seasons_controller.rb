module Api
  module Tournaments
    class SeasonsController < ApplicationController
      before_action :set_season, only: [:show, :update, :destroy]

      # GET /api/seasons
      def index
        @seasons = Season.all
        render json: @seasons
      end

      # POST /api/seasons
      def create
        @season = Season.new(season_params)
        if @season.save
          render json: @season, status: :created
        else
          render json: { errors: @season.errors }, status: :unprocessable_content
        end
      end

      # GET /api/seasons/:id
      def show
        render json: @season
      end

      # PATCH/PUT /api/seasons/:id
      def update
        if @season.update(season_update_params)
          render json: @season
        else
          render json: { errors: @season.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/seasons/:id
      def destroy
        @season.destroy
        head :no_content
      end

      # POST /api/seasons/:id/activate
      def activate
        @season = Season.find(params[:id])
        @season.activate
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Season not found' }, status: :not_found
      end

      # POST /api/seasons/:id/deactivate
      def deactivate
        @season = Season.find(params[:id])
        @season.deactivate
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Season not found' }, status: :not_found
      end

      # POST /api/seasons/:id/finalize
      def finalize_rewards
        @season = Season.find(params[:id])
        @season.finalize_rewards
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Season not found' }, status: :not_found
      end

      private

      def set_season
        @season = Season.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Season not found' }, status: :not_found
      end

      def season_params
        params.fetch(:season, params).permit(:name, :start_date, :end_date, :format, :is_active, :reward_description)
      end

      def season_update_params
        params.fetch(:season, params).permit(:name, :start_date, :end_date, :format, :is_active, :reward_description)
      end
    end
  end
end
