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
          render json: { errors: @tradelisting.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/tradelistings/:id
      def show
        render json: @tradelisting
      end

      # PATCH/PUT /api/tradelistings/:id
      def update
        if @tradelisting.update(tradelisting_params)
          render json: @tradelisting
        else
          render json: { errors: @tradelisting.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/tradelistings/:id
      def destroy
        @tradelisting.destroy
        head :no_content
      end

      private

      def set_tradelisting
        @tradelisting = Tradelisting.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tradelisting not found' }, status: :not_found
      end

      def tradelisting_params
        params.permit(:listing_type, :asking_price, :auction_start_price, :auction_current_bid, :auction_end_time, :foil, :condition, :quantity, :status, :description, :created_at, :expires_at, :seller_id, :card_id, :bids_id)
      end
    end
  end
end
