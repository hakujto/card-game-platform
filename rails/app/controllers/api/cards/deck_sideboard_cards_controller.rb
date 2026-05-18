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
          render json: { errors: @deckSideboardCard.errors }, status: :unprocessable_content
        end
      end

      # GET /api/deck_sideboard_cards/:id
      def show
        render json: @deckSideboardCard
      end

      # PATCH/PUT /api/deck_sideboard_cards/:id
      def update
        if @deckSideboardCard.update(deck_sideboard_card_update_params)
          render json: @deckSideboardCard
        else
          render json: { errors: @deckSideboardCard.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/deck_sideboard_cards/:id
      def destroy
        @deckSideboardCard.destroy
        head :no_content
      end

      # PATCH /api/deck_sideboard_cards/:id/increment
      def increment
        @deckSideboardCard = DeckSideboardCard.find(params[:id])
        amount = params[:amount]
        @deckSideboardCard.increment(amount)
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DeckSideboardCard not found' }, status: :not_found
      end

      # PATCH /api/deck_sideboard_cards/:id/decrement
      def decrement
        @deckSideboardCard = DeckSideboardCard.find(params[:id])
        amount = params[:amount]
        @deckSideboardCard.decrement(amount)
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DeckSideboardCard not found' }, status: :not_found
      end

      private

      def set_deckSideboardCard
        @deckSideboardCard = DeckSideboardCard.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DeckSideboardCard not found' }, status: :not_found
      end

      def deck_sideboard_card_params
        params.fetch(:deck_sideboard_card, params).permit(:quantity, :deck_id, :card_id)
      end

      def deck_sideboard_card_update_params
        params.fetch(:deck_sideboard_card, params).permit(:quantity, :deck_id, :card_id)
      end
    end
  end
end
