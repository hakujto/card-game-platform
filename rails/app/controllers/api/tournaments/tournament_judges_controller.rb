module Api
  module Tournaments
    class TournamentJudgesController < ApplicationController
      before_action :set_tournamentJudge, only: [:show, :update, :destroy]

      # GET /api/tournament_judges
      def index
        @tournament_judges = TournamentJudge.all
        render json: @tournament_judges
      end

      # POST /api/tournament_judges
      def create
        @tournamentJudge = TournamentJudge.new(tournament_judge_params)
        if @tournamentJudge.save
          render json: @tournamentJudge, status: :created
        else
          render json: { errors: @tournamentJudge.errors }, status: :unprocessable_content
        end
      end

      # GET /api/tournament_judges/:id
      def show
        render json: @tournamentJudge
      end

      # PATCH/PUT /api/tournament_judges/:id
      def update
        if @tournamentJudge.update(tournament_judge_update_params)
          render json: @tournamentJudge
        else
          render json: { errors: @tournamentJudge.errors }, status: :unprocessable_content
        end
      end

      # DELETE /api/tournament_judges/:id
      def destroy
        @tournamentJudge.destroy
        head :no_content
      end

      # POST /api/tournament_judges/:id/promote
      def promote_to_head
        @tournamentJudge = TournamentJudge.find(params[:id])
        @tournamentJudge.promote_to_head()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TournamentJudge not found' }, status: :not_found
      end

      # DELETE /api/tournament_judges/:id/remove
      def remove
        @tournamentJudge = TournamentJudge.find(params[:id])
        @tournamentJudge.remove()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TournamentJudge not found' }, status: :not_found
      end

      private

      def set_tournamentJudge
        @tournamentJudge = TournamentJudge.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TournamentJudge not found' }, status: :not_found
      end

      def tournament_judge_params
        params.fetch(:tournament_judge, params).permit(:role, :tournament_id, :player_id)
      end

      def tournament_judge_update_params
        params.fetch(:tournament_judge, params).permit(:role, :tournament_id, :player_id)
      end
    end
  end
end
