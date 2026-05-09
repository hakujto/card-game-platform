module Api
  module Cards
    class CardRulingsController < ApplicationController
      before_action :set_cardRuling, only: [:show, :update, :destroy]

      # GET /api/card_rulings
      def index
        @card_rulings = CardRuling.all
        render json: @card_rulings
      end

      # POST /api/card_rulings
      def create
        @cardRuling = CardRuling.new(card_ruling_params)
        if @cardRuling.save
          render json: @cardRuling, status: :created
        else
          render json: { errors: @cardRuling.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/card_rulings/:id
      def show
        render json: @cardRuling
      end

      # PATCH/PUT /api/card_rulings/:id
      def update
        if @cardRuling.update(card_ruling_params)
          render json: @cardRuling
        else
          render json: { errors: @cardRuling.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/card_rulings/:id
      def destroy
        @cardRuling.destroy
        head :no_content
      end

      private

      def set_cardRuling
        @cardRuling = CardRuling.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'CardRuling not found' }, status: :not_found
      end

      def card_ruling_params
        params.permit(:ruling_text, :published_at, :source, :card_id)
      end
    end
  end
end
