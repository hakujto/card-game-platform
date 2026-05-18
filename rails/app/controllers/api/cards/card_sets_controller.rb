module Api
  module Cards
    class CardSetsController < ApplicationController
      before_action :set_cardSet, only: [:show, :update, :destroy]

      # GET /api/card_sets
      def index
        @card_sets = CardSet.all
        render json: @card_sets
      end

      # POST /api/card_sets
      def create
        @cardSet = CardSet.new(card_set_params)
        if @cardSet.save
          render json: @cardSet, status: :created
        else
          render json: { errors: @cardSet.errors }, status: :unprocessable_content
        end
      end

      # GET /api/card_sets/:id
      def show
        render json: @cardSet
      end

      # PATCH/PUT /api/card_sets/:id
      def update
        if @cardSet.update(card_set_update_params)
          render json: @cardSet
        else
          render json: { errors: @cardSet.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/card_sets/:id
      def destroy
        @cardSet.destroy
        head :no_content
      end

      # GET /api/card_sets/:id/standard-legal
      def is_legal_in_standard
        @cardSet = CardSet.find(params[:id])
        result = @cardSet.is_legal_in_standard()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'CardSet not found' }, status: :not_found
      end

      # GET /api/card_sets/:id/legal
      def is_legal_in_format
        @cardSet = CardSet.find(params[:id])
        result = @cardSet.is_legal_in_format(format)
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'CardSet not found' }, status: :not_found
      end

      # GET /api/card_sets/:id/rarity-count
      def card_count_by_rarity
        @cardSet = CardSet.find(params[:id])
        result = @cardSet.card_count_by_rarity(rarity)
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'CardSet not found' }, status: :not_found
      end

      # POST /api/card_sets/:id/rotate
      def rotate_out
        @cardSet = CardSet.find(params[:id])
        @cardSet.rotate_out()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'CardSet not found' }, status: :not_found
      end

      private

      def set_cardSet
        @cardSet = CardSet.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'CardSet not found' }, status: :not_found
      end

      def card_set_params
        params.fetch(:card_set, params).permit(:name, :code, :release_date, :rotation_date, :set_type, :total_cards, :is_rotated, :description, :logo_url)
      end

      def card_set_update_params
        params.fetch(:card_set, params).permit(:name, :code, :release_date, :rotation_date, :set_type, :total_cards, :is_rotated, :description, :logo_url)
      end
    end
  end
end
