module Api
  module Cards
    class DecksController < ApplicationController
      before_action :set_deck, only: [:show, :update, :destroy]

      # GET /api/decks
      def index
        @decks = Deck.all
        render json: @decks
      end

      # POST /api/decks
      def create
        @deck = Deck.new(deck_params)
        if @deck.save
          render json: @deck, status: :created
        else
          render json: { errors: @deck.errors }, status: :unprocessable_content
        end
      end

      # GET /api/decks/:id
      def show
        render json: @deck
      end

      # PATCH/PUT /api/decks/:id
      def update
        if @deck.update(deck_update_params)
          render json: @deck
        else
          render json: { errors: @deck.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/decks/:id
      def destroy
        @deck.destroy
        head :no_content
      end

      # GET /api/decks/:id/validate
      def validate_size
        @deck = Deck.find(params[:id])
        result = @deck.validate_size()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Deck not found' }, status: :not_found
      end

      # POST /api/decks/:id/cards
      def add_card
        @deck = Deck.find(params[:id])
        card_id = params[:card_id]
        quantity = params[:quantity]
        @deck.add_card(card_id, quantity)
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Deck not found' }, status: :not_found
      end

      # DELETE /api/decks/:id/cards/:card_id
      def remove_card
        @deck = Deck.find(params[:id])
        card_id = params[:card_id]
        @deck.remove_card(card_id)
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Deck not found' }, status: :not_found
      end

      # GET /api/decks/:id/win-rate
      def win_rate
        @deck = Deck.find(params[:id])
        result = @deck.win_rate()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Deck not found' }, status: :not_found
      end

      # POST /api/decks/:id/clone
      def clone
        @deck = Deck.find(params[:id])
        result = @deck.clone()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Deck not found' }, status: :not_found
      end

      # POST /api/decks/:id/publish
      def publish
        @deck = Deck.find(params[:id])
        @deck.publish()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Deck not found' }, status: :not_found
      end

      # POST /api/decks/:id/unpublish
      def unpublish
        @deck = Deck.find(params[:id])
        @deck.unpublish()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Deck not found' }, status: :not_found
      end

      # POST /api/decks/:id/certify
      def certify_tournament_legal
        @deck = Deck.find(params[:id])
        result = @deck.certify_tournament_legal()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Deck not found' }, status: :not_found
      end

      private

      def set_deck
        @deck = Deck.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Deck not found' }, status: :not_found
      end

      def deck_params
        params.fetch(:deck, params).permit(:name, :description, :format, :is_public, :is_tournament_legal, :archetype, :wins, :losses, :draws, :created_at, :updated_at, :player_id)
      end

      def deck_update_params
        params.fetch(:deck, params).permit(:name, :description, :format, :is_public, :is_tournament_legal, :archetype, :wins, :losses, :draws, :created_at, :updated_at, :player_id)
      end
    end
  end
end
