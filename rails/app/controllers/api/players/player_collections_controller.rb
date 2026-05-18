module Api
  module Players
    class PlayerCollectionsController < ApplicationController
      before_action :set_playerCollection, only: [:show, :update, :destroy]

      # GET /api/player_collections
      def index
        @player_collections = PlayerCollection.all
        render json: @player_collections
      end

      # POST /api/player_collections
      def create
        @playerCollection = PlayerCollection.new(player_collection_params)
        if @playerCollection.save
          render json: @playerCollection, status: :created
        else
          render json: { errors: @playerCollection.errors }, status: :unprocessable_content
        end
      end

      # GET /api/player_collections/:id
      def show
        render json: @playerCollection
      end

      # PATCH/PUT /api/player_collections/:id
      def update
        if @playerCollection.update(player_collection_update_params)
          render json: @playerCollection
        else
          render json: { errors: @playerCollection.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/player_collections/:id
      def destroy
        @playerCollection.destroy
        head :no_content
      end

      # POST /api/player_collections/:id/add
      def add
        @playerCollection = PlayerCollection.find(params[:id])
        quantity = params[:quantity]
        @playerCollection.add(quantity)
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'PlayerCollection not found' }, status: :not_found
      end

      # POST /api/player_collections/:id/remove
      def remove
        @playerCollection = PlayerCollection.find(params[:id])
        quantity = params[:quantity]
        @playerCollection.remove(quantity)
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'PlayerCollection not found' }, status: :not_found
      end

      # GET /api/player_collections/:id/value
      def estimated_value
        @playerCollection = PlayerCollection.find(params[:id])
        result = @playerCollection.estimated_value()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'PlayerCollection not found' }, status: :not_found
      end

      private

      def set_playerCollection
        @playerCollection = PlayerCollection.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'PlayerCollection not found' }, status: :not_found
      end

      def player_collection_params
        params.fetch(:player_collection, params).permit(:quantity, :foil, :condition, :acquired_at, :acquired_via, :player_id, :card_id)
      end

      def player_collection_update_params
        params.fetch(:player_collection, params).permit(:quantity, :foil, :condition, :acquired_at, :acquired_via, :player_id, :card_id)
      end
    end
  end
end
