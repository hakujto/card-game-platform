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
          render json: { errors: @craftingRecipe.errors }, status: :unprocessable_content
        end
      end

      # GET /api/crafting_recipes/:id
      def show
        render json: @craftingRecipe
      end

      # PATCH/PUT /api/crafting_recipes/:id
      def update
        if @craftingRecipe.update(crafting_recipe_update_params)
          render json: @craftingRecipe
        else
          render json: { errors: @craftingRecipe.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/crafting_recipes/:id
      def destroy
        @craftingRecipe.destroy
        head :no_content
      end

      # GET /api/crafting_recipes/:id/can-craft
      def can_craft
        @craftingRecipe = CraftingRecipe.find(params[:id])
        result = @craftingRecipe.can_craft(player_id)
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'CraftingRecipe not found' }, status: :not_found
      end

      # POST /api/crafting_recipes/:id/craft
      def execute_craft
        @craftingRecipe = CraftingRecipe.find(params[:id])
        player_id = params[:player_id]
        @craftingRecipe.execute_craft(player_id)
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'CraftingRecipe not found' }, status: :not_found
      end

      # POST /api/crafting_recipes/:id/disable
      def disable
        @craftingRecipe = CraftingRecipe.find(params[:id])
        @craftingRecipe.disable()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'CraftingRecipe not found' }, status: :not_found
      end

      # POST /api/crafting_recipes/:id/enable
      def enable
        @craftingRecipe = CraftingRecipe.find(params[:id])
        @craftingRecipe.enable()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'CraftingRecipe not found' }, status: :not_found
      end

      private

      def set_craftingRecipe
        @craftingRecipe = CraftingRecipe.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'CraftingRecipe not found' }, status: :not_found
      end

      def crafting_recipe_params
        params.fetch(:crafting_recipe, params).permit(:dust_cost, :is_available, :result_card_id)
      end

      def crafting_recipe_update_params
        params.fetch(:crafting_recipe, params).permit(:dust_cost, :is_available, :result_card_id)
      end
    end
  end
end
