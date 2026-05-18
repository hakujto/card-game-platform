module Api
  module Marketplace
    class CardPriceHistoriesController < ApplicationController
      before_action :set_cardPriceHistory, only: [:show, :update, :destroy]

      # GET /api/card_price_histories
      def index
        @card_price_histories = CardPriceHistory.all
        render json: @card_price_histories
      end

      # POST /api/card_price_histories
      def create
        @cardPriceHistory = CardPriceHistory.new(card_price_history_params)
        if @cardPriceHistory.save
          render json: @cardPriceHistory, status: :created
        else
          render json: { errors: @cardPriceHistory.errors }, status: :unprocessable_content
        end
      end

      # GET /api/card_price_histories/:id
      def show
        render json: @cardPriceHistory
      end

      # PATCH/PUT /api/card_price_histories/:id
      def update
        if @cardPriceHistory.update(card_price_history_update_params)
          render json: @cardPriceHistory
        else
          render json: { errors: @cardPriceHistory.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/card_price_histories/:id
      def destroy
        @cardPriceHistory.destroy
        head :no_content
      end

      # GET /api/card_price_histories/:id/change
      def price_change_percent
        @cardPriceHistory = CardPriceHistory.find(params[:id])
        result = @cardPriceHistory.price_change_percent(previous_avg)
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'CardPriceHistory not found' }, status: :not_found
      end

      # GET /api/card_price_histories/:id/spike
      def is_price_spike
        @cardPriceHistory = CardPriceHistory.find(params[:id])
        result = @cardPriceHistory.is_price_spike(threshold_percent)
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'CardPriceHistory not found' }, status: :not_found
      end

      private

      def set_cardPriceHistory
        @cardPriceHistory = CardPriceHistory.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'CardPriceHistory not found' }, status: :not_found
      end

      def card_price_history_params
        params.fetch(:card_price_history, params).permit(:price_date, :avg_price, :min_price, :max_price, :volume, :foil, :card_id)
      end

      def card_price_history_update_params
        params.fetch(:card_price_history, params).permit(:price_date, :avg_price, :min_price, :max_price, :volume, :foil, :card_id)
      end
    end
  end
end
