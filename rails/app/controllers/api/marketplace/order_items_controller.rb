module Api
  module Marketplace
    class OrderItemsController < ApplicationController
      before_action :set_orderItem, only: [:show, :update, :destroy]

      # GET /api/order_items
      def index
        @order_items = OrderItem.all
        render json: @order_items
      end

      # POST /api/order_items
      def create
        @orderItem = OrderItem.new(order_item_params)
        if @orderItem.save
          render json: @orderItem, status: :created
        else
          render json: { errors: @orderItem.errors }, status: :unprocessable_content
        end
      end

      # GET /api/order_items/:id
      def show
        render json: @orderItem
      end

      # PATCH/PUT /api/order_items/:id
      def update
        if @orderItem.update(order_item_update_params)
          render json: @orderItem
        else
          render json: { errors: @orderItem.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/order_items/:id
      def destroy
        @orderItem.destroy
        head :no_content
      end

      # GET /api/order_items/:id/total
      def line_total
        @orderItem = OrderItem.find(params[:id])
        result = @orderItem.line_total()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'OrderItem not found' }, status: :not_found
      end

      private

      def set_orderItem
        @orderItem = OrderItem.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'OrderItem not found' }, status: :not_found
      end

      def order_item_params
        params.fetch(:order_item, params).permit(:quantity, :price_at_purchase, :foil, :order_id, :product_id)
      end

      def order_item_update_params
        params.fetch(:order_item, params).permit(:quantity, :price_at_purchase, :foil, :order_id, :product_id)
      end
    end
  end
end
