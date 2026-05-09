module Api
  module Tournaments
    class TournamentsController < ApplicationController
      before_action :set_tournament, only: [:show, :update, :destroy]

      # GET /api/tournaments
      def index
        @tournaments = Tournament.all
        render json: @tournaments
      end

      # POST /api/tournaments
      def create
        @tournament = Tournament.new(tournament_params)
        if @tournament.save
          render json: @tournament, status: :created
        else
          render json: { errors: @tournament.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/tournaments/:id
      def show
        render json: @tournament
      end

      # PATCH/PUT /api/tournaments/:id
      def update
        if @tournament.update(tournament_params)
          render json: @tournament
        else
          render json: { errors: @tournament.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/tournaments/:id
      def destroy
        @tournament.destroy
        head :no_content
      end

      private

      def set_tournament
        @tournament = Tournament.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tournament not found' }, status: :not_found
      end

      def tournament_params
        params.permit(:name, :description, :format, :tournament_type, :status, :max_players, :entry_fee, :prize_pool, :start_time, :end_time, :is_online, :location, :rules_text, :created_at, :season_id, :organizer_id, :registrations_id, :rounds_id, :prizes_id)
      end
    end
  end
end
