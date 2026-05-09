module Api
  module Cards
    class DeckSideboardCardsController < ApplicationController
      before_action :set_deckSideboardCard, only: [:show, :update, :destroy]

      # GET /api/deck_sideboard_cards
      def index
        @deck_sideboard_cards = DeckSideboardCard.all
        render json: @deck_sideboard_cards
      end

      # POST /api/deck_sideboard_cards
      def create
        @deckSideboardCard = DeckSideboardCard.new(deck_sideboard_card_params)
        if @deckSideboardCard.save
          render json: @deckSideboardCard, status: :created
        else
          render json: { errors: @deckSideboardCard.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/deck_sideboard_cards/:id
      def show
        render json: @deckSideboardCard
      end

      # PATCH/PUT /api/deck_sideboard_cards/:id
      def update
        if @deckSideboardCard.update(deck_sideboard_card_params)
          render json: @deckSideboardCard
        else
          render json: { errors: @deckSideboardCard.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/deck_sideboard_cards/:id
      def destroy
        @deckSideboardCard.destroy
        head :no_content
      end

      private

      def set_deckSideboardCard
        @deckSideboardCard = DeckSideboardCard.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DeckSideboardCard not found' }, status: :not_found
      end

      def deck_sideboard_card_params
        params.permit(:quantity, :deck_id, :card_id)
      end
    end
  end
end
