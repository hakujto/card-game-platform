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
          render json: { errors: @deck.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/decks/:id
      def show
        render json: @deck
      end

      # PATCH/PUT /api/decks/:id
      def update
        if @deck.update(deck_params)
          render json: @deck
        else
          render json: { errors: @deck.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/decks/:id
      def destroy
        @deck.destroy
        head :no_content
      end

      private

      def set_deck
        @deck = Deck.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Deck not found' }, status: :not_found
      end

      def deck_params
        params.permit(:name, :description, :format, :is_public, :is_tournament_legal, :archetype, :wins, :losses, :created_at, :updated_at, :player_id)
      end
    end
  end
end
