module Api
  module Cards
    class CardAbilitiesController < ApplicationController
      before_action :set_cardAbility, only: [:show, :update, :destroy]

      # GET /api/card_abilities
      def index
        @card_abilities = CardAbility.all
        render json: @card_abilities
      end

      # POST /api/card_abilities
      def create
        @cardAbility = CardAbility.new(card_ability_params)
        if @cardAbility.save
          render json: @cardAbility, status: :created
        else
          render json: { errors: @cardAbility.errors }, status: :unprocessable_content
        end
      end

      # GET /api/card_abilities/:id
      def show
        render json: @cardAbility
      end

      # PATCH/PUT /api/card_abilities/:id
      def update
        if @cardAbility.update(card_ability_update_params)
          render json: @cardAbility
        else
          render json: { errors: @cardAbility.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/card_abilities/:id
      def destroy
        @cardAbility.destroy
        head :no_content
      end

      # GET /api/card_abilities/:id/usable
      def is_usable_at
        @cardAbility = CardAbility.find(params[:id])
        result = @cardAbility.is_usable_at(timing)
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'CardAbility not found' }, status: :not_found
      end

      # GET /api/card_abilities/:id/describe
      def describe
        @cardAbility = CardAbility.find(params[:id])
        result = @cardAbility.describe()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'CardAbility not found' }, status: :not_found
      end

      private

      def set_cardAbility
        @cardAbility = CardAbility.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'CardAbility not found' }, status: :not_found
      end

      def card_ability_params
        params.fetch(:card_ability, params).permit(:ability_type, :keyword, :ability_text, :timing, :card_id)
      end

      def card_ability_update_params
        params.fetch(:card_ability, params).permit(:ability_type, :keyword, :ability_text, :timing, :card_id)
      end
    end
  end
end
