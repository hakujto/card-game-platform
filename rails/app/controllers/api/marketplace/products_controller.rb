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
          render json: { errors: @product.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/products/:id
      def show
        render json: @product
      end

      # PATCH/PUT /api/products/:id
      def update
        if @product.update(product_params)
          render json: @product
        else
          render json: { errors: @product.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/products/:id
      def destroy
        @product.destroy
        head :no_content
      end

      private

      def set_product
        @product = Product.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Product not found' }, status: :not_found
      end

      def product_params
        params.permit(:name, :product_type, :price, :stock, :active, :discount_percent, :description, :image_url, :featured, :card_id, :card_set_id)
      end
    end
  end
end
