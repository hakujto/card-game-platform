module Api
  module Cards
    class DeckTagsController < ApplicationController
      before_action :set_deckTag, only: [:show, :update, :destroy]

      # GET /api/deck_tags
      def index
        @deck_tags = DeckTag.all
        render json: @deck_tags
      end

      # POST /api/deck_tags
      def create
        @deckTag = DeckTag.new(deck_tag_params)
        if @deckTag.save
          render json: @deckTag, status: :created
        else
          render json: { errors: @deckTag.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/deck_tags/:id
      def show
        render json: @deckTag
      end

      # PATCH/PUT /api/deck_tags/:id
      def update
        if @deckTag.update(deck_tag_params)
          render json: @deckTag
        else
          render json: { errors: @deckTag.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/deck_tags/:id
      def destroy
        @deckTag.destroy
        head :no_content
      end

      private

      def set_deckTag
        @deckTag = DeckTag.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'DeckTag not found' }, status: :not_found
      end

      def deck_tag_params
        params.permit(:name, :color)
      end
    end
  end
end
