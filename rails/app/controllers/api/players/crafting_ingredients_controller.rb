module Api
  module Players
    class CraftingIngredientsController < ApplicationController
      before_action :set_craftingIngredient, only: [:show, :destroy]

      # GET /api/crafting_ingredients
      def index
        @crafting_ingredients = CraftingIngredient.all
        render json: @crafting_ingredients
      end

      # POST /api/crafting_ingredients
      def create
        @craftingIngredient = CraftingIngredient.new(crafting_ingredient_params)
        if @craftingIngredient.save
          render json: @craftingIngredient, status: :created
        else
          render json: { errors: @craftingIngredient.errors }, status: :unprocessable_content
        end
      end

      # GET /api/crafting_ingredients/:id
      def show
        render json: @craftingIngredient
      end

      # DELETE /api/crafting_ingredients/:id
      def destroy
        @craftingIngredient.destroy
        head :no_content
      end

      private

      def set_craftingIngredient
        @craftingIngredient = CraftingIngredient.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'CraftingIngredient not found' }, status: :not_found
      end

      def crafting_ingredient_params
        params.fetch(:crafting_ingredient, params).permit(:quantity, :recipe_id, :card_id)
      end

      def crafting_ingredient_update_params
        params.fetch(:crafting_ingredient, params).permit(:quantity, :recipe_id, :card_id)
      end
    end
  end
end
