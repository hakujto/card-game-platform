module Api
  module Cards
    class CardsController < ApplicationController
      before_action :set_card, only: [:show, :update, :destroy]

      # GET /api/cards
      def index
        @cards = Card.all
        render json: @cards
      end

      # POST /api/cards
      def create
        @card = Card.new(card_params)
        if @card.save
          render json: @card, status: :created
        else
          render json: { errors: @card.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/cards/:id
      def show
        render json: @card
      end

      # PATCH/PUT /api/cards/:id
      def update
        if @card.update(card_params)
          render json: @card
        else
          render json: { errors: @card.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/cards/:id
      def destroy
        @card.destroy
        head :no_content
      end

      private

      def set_card
        @card = Card.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Card not found' }, status: :not_found
      end

      def card_params
        params.permit(:name, :card_type, :rarity, :mana_cost, :mana_colors, :attack, :defense, :loyalty, :description, :flavor_text, :image_url, :artist_name, :legal_formats, :is_banned, :is_restricted, :power_level, :set_id, :rulings_id, :abilities_id)
      end
    end
  end
end
