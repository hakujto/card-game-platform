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
          render json: { errors: @tradeTransaction.errors }, status: :unprocessable_content
        end
      end

      # GET /api/trade_transactions/:id
      def show
        render json: @tradeTransaction
      end

      # PATCH/PUT /api/trade_transactions/:id
      def update
        if @tradeTransaction.update(trade_transaction_update_params)
          render json: @tradeTransaction
        else
          render json: { errors: @tradeTransaction.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/trade_transactions/:id
      def destroy
        @tradeTransaction.destroy
        head :no_content
      end

      # POST /api/trade_transactions/:id/complete
      def complete
        @tradeTransaction = TradeTransaction.find(params[:id])
        @tradeTransaction.complete
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeTransaction not found' }, status: :not_found
      end

      # POST /api/trade_transactions/:id/refund
      def refund
        @tradeTransaction = TradeTransaction.find(params[:id])
        @tradeTransaction.refund
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeTransaction not found' }, status: :not_found
      end

      # POST /api/trade_transactions/:id/dispute
      def open_dispute
        @tradeTransaction = TradeTransaction.find(params[:id])
        reason = params[:reason]
        @tradeTransaction.open_dispute(reason)
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeTransaction not found' }, status: :not_found
      end

      private

      def set_tradeTransaction
        @tradeTransaction = TradeTransaction.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeTransaction not found' }, status: :not_found
      end

      def trade_transaction_params
        params.fetch(:trade_transaction, params).permit(:final_price, :platform_fee, :status, :completed_at, :listing_id, :buyer_id, :seller_id)
      end

      def trade_transaction_update_params
        params.fetch(:trade_transaction, params).permit(:final_price, :platform_fee, :status, :completed_at, :listing_id, :buyer_id, :seller_id)
      end
    end
  end
end
