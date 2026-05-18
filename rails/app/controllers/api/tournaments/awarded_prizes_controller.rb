module Api
  module Tournaments
    class AwardedPrizesController < ApplicationController
      before_action :set_awardedPrize, only: [:show, :update, :destroy]

      # GET /api/awarded_prizes
      def index
        @awarded_prizes = AwardedPrize.all
        render json: @awarded_prizes
      end

      # POST /api/awarded_prizes
      def create
        @awardedPrize = AwardedPrize.new(awarded_prize_params)
        if @awardedPrize.save
          render json: @awardedPrize, status: :created
        else
          render json: { errors: @awardedPrize.errors }, status: :unprocessable_content
        end
      end

      # GET /api/awarded_prizes/:id
      def show
        render json: @awardedPrize
      end

      # PATCH/PUT /api/awarded_prizes/:id
      def update
        if @awardedPrize.update(awarded_prize_update_params)
          render json: @awardedPrize
        else
          render json: { errors: @awardedPrize.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/awarded_prizes/:id
      def destroy
        @awardedPrize.destroy
        head :no_content
      end

      # POST /api/awarded_prizes/:id/claim
      def claim
        @awardedPrize = AwardedPrize.find(params[:id])
        @awardedPrize.claim()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'AwardedPrize not found' }, status: :not_found
      end

      private

      def set_awardedPrize
        @awardedPrize = AwardedPrize.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'AwardedPrize not found' }, status: :not_found
      end

      def awarded_prize_params
        params.fetch(:awarded_prize, params).permit(:final_placement, :awarded_at, :claimed, :claimed_at, :prize_id, :player_id)
      end

      def awarded_prize_update_params
        params.fetch(:awarded_prize, params).permit(:final_placement, :awarded_at, :claimed, :claimed_at, :prize_id, :player_id)
      end
    end
  end
end
