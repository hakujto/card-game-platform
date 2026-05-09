module Api
  module Marketplace
    class OrdersController < ApplicationController
      before_action :set_order, only: [:show, :update, :destroy]

      # GET /api/orders
      def index
        @orders = Order.all
        render json: @orders
      end

      # POST /api/orders
      def create
        @order = Order.new(order_params)
        if @order.save
          render json: @order, status: :created
        else
          render json: { errors: @order.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/orders/:id
      def show
        render json: @order
      end

      # PATCH/PUT /api/orders/:id
      def update
        if @order.update(order_params)
          render json: @order
        else
          render json: { errors: @order.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/orders/:id
      def destroy
        @order.destroy
        head :no_content
      end

      private

      def set_order
        @order = Order.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      def order_params
        params.permit(:status, :total, :discount_applied, :currency, :payment_method, :payment_reference, :shipping_address, :tracking_number, :created_at, :paid_at, :shipped_at, :player_id, :items_id, :coupon_id)
      end
    end
  end
end
