module Api
  module Players
    class FriendshipsController < ApplicationController
      before_action :set_friendship, only: [:show, :update, :destroy]

      # GET /api/friendships
      def index
        @friendships = Friendship.all
        render json: @friendships
      end

      # POST /api/friendships
      def create
        @friendship = Friendship.new(friendship_params)
        if @friendship.save
          render json: @friendship, status: :created
        else
          render json: { errors: @friendship.errors }, status: :unprocessable_content
        end
      end

      # GET /api/friendships/:id
      def show
        render json: @friendship
      end

      # PATCH/PUT /api/friendships/:id
      def update
        if @friendship.update(friendship_update_params)
          render json: @friendship
        else
          render json: { errors: @friendship.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/friendships/:id
      def destroy
        @friendship.destroy
        head :no_content
      end

      # POST /api/friendships/:id/accept
      def accept
        @friendship = Friendship.find(params[:id])
        @friendship.accept()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Friendship not found' }, status: :not_found
      end

      # POST /api/friendships/:id/decline
      def decline
        @friendship = Friendship.find(params[:id])
        @friendship.decline()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Friendship not found' }, status: :not_found
      end

      # POST /api/friendships/:id/block
      def block
        @friendship = Friendship.find(params[:id])
        @friendship.block()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Friendship not found' }, status: :not_found
      end

      private

      def set_friendship
        @friendship = Friendship.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Friendship not found' }, status: :not_found
      end

      def friendship_params
        params.fetch(:friendship, params).permit(:status, :created_at, :requester_id, :receiver_id)
      end

      def friendship_update_params
        params.fetch(:friendship, params).permit(:status, :created_at, :requester_id, :receiver_id)
      end
    end
  end
end
