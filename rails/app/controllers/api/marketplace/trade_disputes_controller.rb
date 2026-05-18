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
          render json: { errors: @tradeDispute.errors }, status: :unprocessable_content
        end
      end

      # GET /api/trade_disputes/:id
      def show
        render json: @tradeDispute
      end

      # PATCH/PUT /api/trade_disputes/:id
      def update
        if @tradeDispute.update(trade_dispute_update_params)
          render json: @tradeDispute
        else
          render json: { errors: @tradeDispute.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/trade_disputes/:id
      def destroy
        @tradeDispute.destroy
        head :no_content
      end

      # POST /api/trade_disputes/:id/escalate
      def escalate
        @tradeDispute = TradeDispute.find(params[:id])
        @tradeDispute.escalate()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeDispute not found' }, status: :not_found
      end

      # POST /api/trade_disputes/:id/resolve
      def resolve
        @tradeDispute = TradeDispute.find(params[:id])
        resolution_text = params[:resolution_text]
        @tradeDispute.resolve(resolution_text)
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeDispute not found' }, status: :not_found
      end

      # POST /api/trade_disputes/:id/review
      def review
        @tradeDispute = TradeDispute.find(params[:id])
        @tradeDispute.review()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeDispute not found' }, status: :not_found
      end

      private

      def set_tradeDispute
        @tradeDispute = TradeDispute.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeDispute not found' }, status: :not_found
      end

      def trade_dispute_params
        params.fetch(:trade_dispute, params).permit(:reason, :description, :status, :resolution, :opened_at, :resolved_at, :transaction_id, :opened_by_id, :resolved_by_id)
      end

      def trade_dispute_update_params
        params.fetch(:trade_dispute, params).permit(:reason, :description, :status, :resolution, :opened_at, :resolved_at, :transaction_id, :opened_by_id, :resolved_by_id)
      end
    end
  end
end
