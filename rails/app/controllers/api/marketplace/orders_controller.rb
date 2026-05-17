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
          render json: { errors: @order.errors }, status: :unprocessable_content
        end
      end

      # GET /api/orders/:id
      def show
        render json: @order
      end

      # PATCH/PUT /api/orders/:id
      def update
        if @order.update(order_update_params)
          render json: @order
        else
          render json: { errors: @order.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/orders/:id
      def destroy
        @order.destroy
        head :no_content
      end

      # DELETE /api/orders/:id/cancel
      def cancel
        @order = Order.find(params[:id])
        @order.cancel
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      # POST /api/orders/:id/pay
      def pay
        @order = Order.find(params[:id])
        payment_ref = params[:payment_ref]
        result = @order.pay(payment_ref)
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      # GET /api/orders/:id/total
      def calculate_total
        @order = Order.find(params[:id])
        result = @order.calculate_total
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      # PATCH /api/orders/:id/discount
      def apply_discount
        @order = Order.find(params[:id])
        percent = params[:percent]
        result = @order.apply_discount(percent)
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      # POST /api/orders/:id/refund
      def refund
        @order = Order.find(params[:id])
        @order.refund
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      private

      def set_order
        @order = Order.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      def order_params
        params.fetch(:order, params).permit(:status, :total, :discount_applied, :currency, :payment_method, :payment_reference, :shipping_address, :tracking_number, :created_at, :paid_at, :shipped_at, :player_id, :coupon_id)
      end

      def order_update_params
        params.fetch(:order, params).permit(:status, :total, :discount_applied, :currency, :payment_method, :payment_reference, :shipping_address, :tracking_number, :created_at, :paid_at, :shipped_at, :player_id, :coupon_id)
      end
    end
  end
end
