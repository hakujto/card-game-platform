module Api
  module Cards
    class CardsController < ApplicationController
      before_action :set_card, only: [:show, :update]

      # GET /api/cards?q=...
      def index
        q = params[:q]
        @cards = q.present? ? Card.where(Card.arel_table[:name].matches("%#{q}%").or(Card.arel_table[:artist_name].matches("%#{q}%"))) : Card.all
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

      # POST /api/cards/:id/ban
      def ban
        unless current_user&.role.in?(["admin", "moderator"])
          render json: { error: 'Insufficient role for ban' }, status: :forbidden
          return
        end
        @card = Card.find(params[:id])
        @card.ban()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Card not found' }, status: :not_found
      end

      # POST /api/cards/:id/unban
      def unban
        unless current_user&.role.in?(["admin", "moderator"])
          render json: { error: 'Insufficient role for unban' }, status: :forbidden
          return
        end
        @card = Card.find(params[:id])
        @card.unban()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Card not found' }, status: :not_found
      end

      # POST /api/cards/:id/restrict
      def restrict
        unless current_user&.role.in?(["admin", "moderator"])
          render json: { error: 'Insufficient role for restrict' }, status: :forbidden
          return
        end
        @card = Card.find(params[:id])
        @card.restrict()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Card not found' }, status: :not_found
      end

      # POST /api/cards/:id/unrestrict
      def unrestrict
        unless current_user&.role.in?(["admin", "moderator"])
          render json: { error: 'Insufficient role for unrestrict' }, status: :forbidden
          return
        end
        @card = Card.find(params[:id])
        @card.unrestrict()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Card not found' }, status: :not_found
      end

      # PUT /api/cards/:id/replace
      def replace
        unless current_user&.role.in?(["admin"])
          render json: { error: 'Insufficient role for replace' }, status: :forbidden
          return
        end
        @card = Card.find(params[:id])
        data = params[:data]
        result = @card.replace(data)
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Card not found' }, status: :not_found
      end

      # GET /api/cards/:id/value
      def calculate_value
        @card = Card.find(params[:id])
        result = @card.calculate_value()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Card not found' }, status: :not_found
      end

      # POST /api/cards/:id/rarity-bonus
      def apply_rarity_bonus
        @card = Card.find(params[:id])
        multiplier = params[:multiplier]
        result = @card.apply_rarity_bonus(multiplier)
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Card not found' }, status: :not_found
      end

      # GET /api/cards/:id/legal
      def is_legal_in_format
        @card = Card.find(params[:id])
        result = @card.is_legal_in_format(format)
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
        params.fetch(:card, params).permit(:public_id, :name, :card_type, :rarity, :mana_cost, :mana_colors, :attack, :defense, :loyalty, :description, :flavor_text, :image_url, :artist_name, :legal_formats, :is_banned, :is_restricted, :power_level, :metadata, :total_copies_in_circulation, :set_id)
      end

      def card_update_params
        params.fetch(:card, params).permit(:public_id, :name, :card_type, :rarity, :mana_cost, :mana_colors, :attack, :defense, :loyalty, :description, :flavor_text, :image_url, :artist_name, :legal_formats, :power_level, :metadata, :total_copies_in_circulation, :set_id)
      end
    end
  end
end
