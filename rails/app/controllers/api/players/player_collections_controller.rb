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
          render json: { errors: @playerCollection.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/player_collections/:id
      def show
        render json: @playerCollection
      end

      # PATCH/PUT /api/player_collections/:id
      def update
        if @playerCollection.update(player_collection_params)
          render json: @playerCollection
        else
          render json: { errors: @playerCollection.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/player_collections/:id
      def destroy
        @playerCollection.destroy
        head :no_content
      end

      private

      def set_playerCollection
        @playerCollection = PlayerCollection.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'PlayerCollection not found' }, status: :not_found
      end

      def player_collection_params
        params.permit(:quantity, :foil, :condition, :acquired_at, :acquired_via, :player_id, :card_id)
      end
    end
  end
end
