module Api
  module Marketplace
    class CouponsController < ApplicationController
      before_action :set_coupon, only: [:show, :update, :destroy]

      # GET /api/coupons
      def index
        @coupons = Coupon.all
        render json: @coupons
      end

      # POST /api/coupons
      def create
        @coupon = Coupon.new(coupon_params)
        if @coupon.save
          render json: @coupon, status: :created
        else
          render json: { errors: @coupon.errors }, status: :unprocessable_content
        end
      end

      # GET /api/coupons/:id
      def show
        render json: @coupon
      end

      # PATCH/PUT /api/coupons/:id
      def update
        if @coupon.update(coupon_update_params)
          render json: @coupon
        else
          render json: { errors: @coupon.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/coupons/:id
      def destroy
        @coupon.destroy
        head :no_content
      end

      # POST /api/coupons/:id/redeem
      def redeem
        @coupon = Coupon.find(params[:id])
        @coupon.redeem
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Coupon not found' }, status: :not_found
      end

      # POST /api/coupons/:id/deactivate
      def deactivate
        @coupon = Coupon.find(params[:id])
        @coupon.deactivate
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Coupon not found' }, status: :not_found
      end

      private

      def set_coupon
        @coupon = Coupon.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Coupon not found' }, status: :not_found
      end

      def coupon_params
        params.fetch(:coupon, params).permit(:code, :discount_type, :discount_value, :min_order_value, :max_uses, :uses_count, :valid_from, :valid_until, :is_active)
      end

      def coupon_update_params
        params.fetch(:coupon, params).permit(:code, :discount_type, :discount_value, :min_order_value, :max_uses, :uses_count, :valid_from, :valid_until, :is_active)
      end
    end
  end
end
