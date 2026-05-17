module Api
  module Marketplace
    class TradelistingsController < ApplicationController
      before_action :set_tradelisting, only: [:show, :update, :destroy]

      # GET /api/tradelistings
      def index
        @tradelistings = Tradelisting.all
        render json: @tradelistings
      end

      # POST /api/tradelistings
      def create
        @tradelisting = Tradelisting.new(tradelisting_params)
        if @tradelisting.save
          render json: @tradelisting, status: :created
        else
          render json: { errors: @tradelisting.errors }, status: :unprocessable_content
        end
      end

      # GET /api/tradelistings/:id
      def show
        render json: @tradelisting
      end

      # PATCH/PUT /api/tradelistings/:id
      def update
        if @tradelisting.update(tradelisting_update_params)
          render json: @tradelisting
        else
          render json: { errors: @tradelisting.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/tradelistings/:id
      def destroy
        @tradelisting.destroy
        head :no_content
      end

      # POST /api/tradelistings/:id/close
      def close
        @tradelisting = Tradelisting.find(params[:id])
        @tradelisting.close
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tradelisting not found' }, status: :not_found
      end

      # PATCH /api/tradelistings/:id/extend
      def extend
        @tradelisting = Tradelisting.find(params[:id])
        days = params[:days]
        @tradelisting.extend(days)
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tradelisting not found' }, status: :not_found
      end

      # DELETE /api/tradelistings/:id/cancel
      def cancel
        @tradelisting = Tradelisting.find(params[:id])
        @tradelisting.cancel
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tradelisting not found' }, status: :not_found
      end

      private

      def set_tradelisting
        @tradelisting = Tradelisting.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tradelisting not found' }, status: :not_found
      end

      def tradelisting_params
        params.fetch(:tradelisting, params).permit(:listing_type, :asking_price, :auction_start_price, :auction_current_bid, :auction_end_time, :foil, :condition, :quantity, :status, :description, :created_at, :expires_at, :seller_id, :card_id)
      end

      def tradelisting_update_params
        params.fetch(:tradelisting, params).permit(:listing_type, :asking_price, :auction_start_price, :auction_current_bid, :auction_end_time, :foil, :condition, :quantity, :status, :description, :created_at, :expires_at, :seller_id, :card_id)
      end
    end
  end
end
