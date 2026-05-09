module Api
  module Tournaments
    class TournamentRegistrationsController < ApplicationController
      before_action :set_tournamentRegistration, only: [:show, :update, :destroy]

      # GET /api/tournament_registrations
      def index
        @tournament_registrations = TournamentRegistration.all
        render json: @tournament_registrations
      end

      # POST /api/tournament_registrations
      def create
        @tournamentRegistration = TournamentRegistration.new(tournament_registration_params)
        if @tournamentRegistration.save
          render json: @tournamentRegistration, status: :created
        else
          render json: { errors: @tournamentRegistration.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/tournament_registrations/:id
      def show
        render json: @tournamentRegistration
      end

      # PATCH/PUT /api/tournament_registrations/:id
      def update
        if @tournamentRegistration.update(tournament_registration_params)
          render json: @tournamentRegistration
        else
          render json: { errors: @tournamentRegistration.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/tournament_registrations/:id
      def destroy
        @tournamentRegistration.destroy
        head :no_content
      end

      private

      def set_tournamentRegistration
        @tournamentRegistration = TournamentRegistration.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TournamentRegistration not found' }, status: :not_found
      end

      def tournament_registration_params
        params.permit(:status, :seed, :final_standing, :points_earned, :registered_at, :tournament_id, :player_id, :deck_id)
      end
    end
  end
end
