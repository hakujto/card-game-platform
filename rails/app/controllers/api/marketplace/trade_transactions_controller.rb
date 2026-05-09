module Api
  module Marketplace
    class TradeTransactionsController < ApplicationController
      before_action :set_tradeTransaction, only: [:show, :update, :destroy]

      # GET /api/trade_transactions
      def index
        @trade_transactions = TradeTransaction.all
        render json: @trade_transactions
      end

      # POST /api/trade_transactions
      def create
        @tradeTransaction = TradeTransaction.new(trade_transaction_params)
        if @tradeTransaction.save
          render json: @tradeTransaction, status: :created
        else
          render json: { errors: @tradeTransaction.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/trade_transactions/:id
      def show
        render json: @tradeTransaction
      end

      # PATCH/PUT /api/trade_transactions/:id
      def update
        if @tradeTransaction.update(trade_transaction_params)
          render json: @tradeTransaction
        else
          render json: { errors: @tradeTransaction.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/trade_transactions/:id
      def destroy
        @tradeTransaction.destroy
        head :no_content
      end

      private

      def set_tradeTransaction
        @tradeTransaction = TradeTransaction.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeTransaction not found' }, status: :not_found
      end

      def trade_transaction_params
        params.permit(:final_price, :platform_fee, :status, :completed_at, :listing_id, :buyer_id, :seller_id)
      end
    end
  end
end
