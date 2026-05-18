module Api
  module Marketplace
    class ProductsController < ApplicationController
      before_action :set_product, only: [:show, :update, :destroy]

      # GET /api/products
      def index
        @products = Product.all
        render json: @products
      end

      # POST /api/products
      def create
        @product = Product.new(product_params)
        if @product.save
          render json: @product, status: :created
        else
          render json: { errors: @product.errors }, status: :unprocessable_content
        end
      end

      # GET /api/products/:id
      def show
        render json: @product
      end

      # PATCH/PUT /api/products/:id
      def update
        if @product.update(product_update_params)
          render json: @product
        else
          render json: { errors: @product.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/products/:id
      def destroy
        @product.destroy
        head :no_content
      end

      # POST /api/products/:id/activate
      def activate
        @product = Product.find(params[:id])
        @product.activate()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Product not found' }, status: :not_found
      end

      # POST /api/products/:id/deactivate
      def deactivate
        @product = Product.find(params[:id])
        @product.deactivate()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Product not found' }, status: :not_found
      end

      # PATCH /api/products/:id/discount
      def apply_discount
        @product = Product.find(params[:id])
        percent = params[:percent]
        result = @product.apply_discount(percent)
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Product not found' }, status: :not_found
      end

      # POST /api/products/:id/restock
      def restock
        @product = Product.find(params[:id])
        quantity = params[:quantity]
        @product.restock(quantity)
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Product not found' }, status: :not_found
      end

      # GET /api/products/:id/effective-price
      def effective_price
        @product = Product.find(params[:id])
        result = @product.effective_price()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Product not found' }, status: :not_found
      end

      # GET /api/products/:id/in-stock
      def is_in_stock
        @product = Product.find(params[:id])
        result = @product.is_in_stock()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Product not found' }, status: :not_found
      end

      private

      def set_product
        @product = Product.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Product not found' }, status: :not_found
      end

      def product_params
        params.fetch(:product, params).permit(:name, :product_type, :price, :stock, :active, :discount_percent, :description, :image_url, :featured, :card_id, :card_set_id)
      end

      def product_update_params
        params.fetch(:product, params).permit(:name, :product_type, :price, :stock, :active, :discount_percent, :description, :image_url, :featured, :card_id, :card_set_id)
      end
    end
  end
end
