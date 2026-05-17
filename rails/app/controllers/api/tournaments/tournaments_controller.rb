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
          render json: { errors: @tournament.errors }, status: :unprocessable_content
        end
      end

      # GET /api/tournaments/:id
      def show
        render json: @tournament
      end

      # PATCH/PUT /api/tournaments/:id
      def update
        if @tournament.update(tournament_update_params)
          render json: @tournament
        else
          render json: { errors: @tournament.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/tournaments/:id
      def destroy
        @tournament.destroy
        head :no_content
      end

      # POST /api/tournaments/:id/start
      def start
        @tournament = Tournament.find(params[:id])
        @tournament.start
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tournament not found' }, status: :not_found
      end

      # POST /api/tournaments/:id/cancel
      def cancel
        @tournament = Tournament.find(params[:id])
        @tournament.cancel
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tournament not found' }, status: :not_found
      end

      # POST /api/tournaments/:id/complete
      def complete
        @tournament = Tournament.find(params[:id])
        @tournament.complete
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tournament not found' }, status: :not_found
      end

      # POST /api/tournaments/:id/rounds
      def generate_round
        @tournament = Tournament.find(params[:id])
        @tournament.generate_round
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tournament not found' }, status: :not_found
      end

      # GET /api/tournaments/:id/prizes
      def calculate_prize_distribution
        @tournament = Tournament.find(params[:id])
        result = @tournament.calculate_prize_distribution
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tournament not found' }, status: :not_found
      end

      private

      def set_tournament
        @tournament = Tournament.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tournament not found' }, status: :not_found
      end

      def tournament_params
        params.fetch(:tournament, params).permit(:name, :description, :format, :tournament_type, :status, :max_players, :entry_fee, :prize_pool, :start_time, :end_time, :is_online, :location, :rules_text, :created_at, :season_id, :organizer_id)
      end

      def tournament_update_params
        params.fetch(:tournament, params).permit(:name, :description, :format, :tournament_type, :status, :max_players, :entry_fee, :prize_pool, :start_time, :end_time, :is_online, :location, :rules_text, :created_at, :season_id, :organizer_id)
      end
    end
  end
end
