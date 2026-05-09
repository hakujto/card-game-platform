module Api
  module Marketplace
    class TradeDisputesController < ApplicationController
      before_action :set_tradeDispute, only: [:show, :update, :destroy]

      # GET /api/trade_disputes
      def index
        @trade_disputes = TradeDispute.all
        render json: @trade_disputes
      end

      # POST /api/trade_disputes
      def create
        @tradeDispute = TradeDispute.new(trade_dispute_params)
        if @tradeDispute.save
          render json: @tradeDispute, status: :created
        else
          render json: { errors: @tradeDispute.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/trade_disputes/:id
      def show
        render json: @tradeDispute
      end

      # PATCH/PUT /api/trade_disputes/:id
      def update
        if @tradeDispute.update(trade_dispute_params)
          render json: @tradeDispute
        else
          render json: { errors: @tradeDispute.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/trade_disputes/:id
      def destroy
        @tradeDispute.destroy
        head :no_content
      end

      private

      def set_tradeDispute
        @tradeDispute = TradeDispute.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeDispute not found' }, status: :not_found
      end

      def trade_dispute_params
        params.permit(:reason, :description, :status, :resolution, :opened_at, :resolved_at, :transaction_id, :opened_by_id, :resolved_by_id)
      end
    end
  end
end
