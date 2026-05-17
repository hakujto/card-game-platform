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
          render json: { errors: @card.errors }, status: :unprocessable_content
        end
      end

      # GET /api/cards/:id
      def show
        render json: @card
      end

      # PATCH/PUT /api/cards/:id
      def update
        if @card.update(card_update_params)
          render json: @card
        else
          render json: { errors: @card.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/cards/:id
      def destroy
        @card.destroy
        head :no_content
      end

      # POST /api/cards/:id/ban
      def ban
        @card = Card.find(params[:id])
        @card.ban
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Card not found' }, status: :not_found
      end

      # POST /api/cards/:id/unban
      def unban
        @card = Card.find(params[:id])
        @card.unban
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Card not found' }, status: :not_found
      end

      # POST /api/cards/:id/restrict
      def restrict
        @card = Card.find(params[:id])
        @card.restrict
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Card not found' }, status: :not_found
      end

      # POST /api/cards/:id/unrestrict
      def unrestrict
        @card = Card.find(params[:id])
        @card.unrestrict
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Card not found' }, status: :not_found
      end

      # GET /api/cards/:id/value
      def calculate_value
        @card = Card.find(params[:id])
        result = @card.calculate_value
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Card not found' }, status: :not_found
      end

      private

      def set_card
        @card = Card.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Card not found' }, status: :not_found
      end

      def card_params
        params.fetch(:card, params).permit(:name, :card_type, :rarity, :mana_cost, :mana_colors, :attack, :defense, :loyalty, :description, :flavor_text, :image_url, :artist_name, :legal_formats, :is_banned, :is_restricted, :power_level, :set_id)
      end

      def card_update_params
        params.fetch(:card, params).permit(:name, :card_type, :rarity, :mana_cost, :mana_colors, :attack, :defense, :loyalty, :description, :flavor_text, :image_url, :artist_name, :legal_formats, :is_banned, :is_restricted, :power_level, :set_id)
      end
    end
  end
end
