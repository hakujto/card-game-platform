module Api
  module Marketplace
    class TradeListingsController < ApplicationController
      before_action :set_tradeListing, only: [:show, :update, :destroy]

      # GET /api/trade_listings
      def index
        @trade_listings = TradeListing.all
        render json: @trade_listings
      end

      # POST /api/trade_listings
      def create
        @tradeListing = TradeListing.new(trade_listing_params)
        if @tradeListing.save
          render json: @tradeListing, status: :created
        else
          render json: { errors: @tradeListing.errors }, status: :unprocessable_content
        end
      end

      # GET /api/trade_listings/:id
      def show
        render json: @tradeListing
      end

      # PATCH/PUT /api/trade_listings/:id
      def update
        if @tradeListing.update(trade_listing_update_params)
          render json: @tradeListing
        else
          render json: { errors: @tradeListing.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/trade_listings/:id
      def destroy
        @tradeListing.destroy
        head :no_content
      end

      # POST /api/trade_listings/:id/close
      def close
        @tradeListing = TradeListing.find(params[:id])
        @tradeListing.close()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeListing not found' }, status: :not_found
      end

      # PATCH /api/trade_listings/:id/extend
      def extend
        @tradeListing = TradeListing.find(params[:id])
        days = params[:days]
        @tradeListing.extend(days)
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeListing not found' }, status: :not_found
      end

      # DELETE /api/trade_listings/:id/cancel
      def cancel
        @tradeListing = TradeListing.find(params[:id])
        @tradeListing.cancel()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeListing not found' }, status: :not_found
      end

      # GET /api/trade_listings/:id/expired
      def is_expired
        @tradeListing = TradeListing.find(params[:id])
        result = @tradeListing.is_expired()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeListing not found' }, status: :not_found
      end

      # POST /api/trade_listings/:id/finalize
      def finalize_auction
        @tradeListing = TradeListing.find(params[:id])
        @tradeListing.finalize_auction()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeListing not found' }, status: :not_found
      end

      private

      def set_tradeListing
        @tradeListing = TradeListing.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeListing not found' }, status: :not_found
      end

      def trade_listing_params
        params.fetch(:trade_listing, params).permit(:listing_type, :asking_price, :auction_start_price, :auction_current_bid, :auction_end_time, :foil, :condition, :quantity, :status, :description, :created_at, :expires_at, :seller_id, :card_id)
      end

      def trade_listing_update_params
        params.fetch(:trade_listing, params).permit(:listing_type, :asking_price, :auction_start_price, :auction_current_bid, :auction_end_time, :foil, :condition, :quantity, :status, :description, :created_at, :expires_at, :seller_id, :card_id)
      end
    end
  end
end
