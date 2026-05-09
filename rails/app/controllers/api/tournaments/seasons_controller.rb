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
          render json: { errors: @season.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/seasons/:id
      def show
        render json: @season
      end

      # PATCH/PUT /api/seasons/:id
      def update
        if @season.update(season_params)
          render json: @season
        else
          render json: { errors: @season.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/seasons/:id
      def destroy
        @season.destroy
        head :no_content
      end

      private

      def set_season
        @season = Season.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Season not found' }, status: :not_found
      end

      def season_params
        params.permit(:name, :start_date, :end_date, :format, :is_active, :reward_description)
      end
    end
  end
end
