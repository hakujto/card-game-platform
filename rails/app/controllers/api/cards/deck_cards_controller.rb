module Api
  module Cards
    class DeckCardsController < ApplicationController
      before_action :set_deckCard, only: [:show, :update, :destroy]

      # GET /api/deck_cards
      def index
        @deck_cards = DeckCard.all
        render json: @deck_cards
      end

      # POST /api/deck_cards
      def create
        @deckCard = DeckCard.new(deck_card_params)
        if @deckCard.save
          render json: @deckCard, status: :created
        else
          render json: { errors: @deckCard.errors }, status: :unprocessable_content
        end
      end

      # GET /api/deck_cards/:id
      def show
        render json: @deckCard
      end

      # PATCH/PUT /api/deck_cards/:id
      def update
        if @deckCard.update(deck_card_update_params)
          render json: @deckCard
        else
          render json: { errors: @deckCard.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/deck_cards/:id
      def destroy
        @deckCard.destroy
        head :no_content
      end

      private

      def set_deckCard
        @deckCard = DeckCard.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DeckCard not found' }, status: :not_found
      end

      def deck_card_params
        params.fetch(:deck_card, params).permit(:quantity, :is_commander, :deck_id, :card_id)
      end

      def deck_card_update_params
        params.fetch(:deck_card, params).permit(:quantity, :is_commander, :deck_id, :card_id)
      end
    end
  end
end
