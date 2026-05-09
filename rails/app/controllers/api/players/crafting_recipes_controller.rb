module Api
  module Players
    class CraftingRecipesController < ApplicationController
      before_action :set_craftingRecipe, only: [:show, :update, :destroy]

      # GET /api/crafting_recipes
      def index
        @crafting_recipes = CraftingRecipe.all
        render json: @crafting_recipes
      end

      # POST /api/crafting_recipes
      def create
        @craftingRecipe = CraftingRecipe.new(crafting_recipe_params)
        if @craftingRecipe.save
          render json: @craftingRecipe, status: :created
        else
          render json: { errors: @craftingRecipe.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/crafting_recipes/:id
      def show
        render json: @craftingRecipe
      end

      # PATCH/PUT /api/crafting_recipes/:id
      def update
        if @craftingRecipe.update(crafting_recipe_params)
          render json: @craftingRecipe
        else
          render json: { errors: @craftingRecipe.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/crafting_recipes/:id
      def destroy
        @craftingRecipe.destroy
        head :no_content
      end

      private

      def set_craftingRecipe
        @craftingRecipe = CraftingRecipe.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'CraftingRecipe not found' }, status: :not_found
      end

      def crafting_recipe_params
        params.permit(:dust_cost, :is_available, :result_card_id)
      end
    end
  end
end
