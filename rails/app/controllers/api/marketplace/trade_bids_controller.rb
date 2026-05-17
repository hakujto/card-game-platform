module Api
  module Marketplace
    class TradeBidsController < ApplicationController
      before_action :set_tradeBid, only: [:show, :update, :destroy]

      # GET /api/trade_bids
      def index
        @trade_bids = TradeBid.all
        render json: @trade_bids
      end

      # POST /api/trade_bids
      def create
        @tradeBid = TradeBid.new(trade_bid_params)
        if @tradeBid.save
          render json: @tradeBid, status: :created
        else
          render json: { errors: @tradeBid.errors }, status: :unprocessable_content
        end
      end

      # GET /api/trade_bids/:id
      def show
        render json: @tradeBid
      end

      # PATCH/PUT /api/trade_bids/:id
      def update
        if @tradeBid.update(trade_bid_update_params)
          render json: @tradeBid
        else
          render json: { errors: @tradeBid.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/trade_bids/:id
      def destroy
        @tradeBid.destroy
        head :no_content
      end

      private

      def set_tradeBid
        @tradeBid = TradeBid.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeBid not found' }, status: :not_found
      end

      def trade_bid_params
        params.fetch(:trade_bid, params).permit(:amount, :placed_at, :is_winning, :listing_id, :bidder_id)
      end

      def trade_bid_update_params
        params.fetch(:trade_bid, params).permit(:amount, :placed_at, :is_winning, :listing_id, :bidder_id)
      end
    end
  end
end
