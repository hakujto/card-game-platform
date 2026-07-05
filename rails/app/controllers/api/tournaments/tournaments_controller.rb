module Api
  module Tournaments
    class TournamentsController < ApplicationController
      before_action :set_tournament, only: [:show, :update]

      # GET /api/tournaments?q=...
      def index
        q = params[:q]
        @tournaments = q.present? ? Tournament.where(Tournament.arel_table[:name].matches("%#{q}%").or(Tournament.arel_table[:description].matches("%#{q}%"))) : Tournament.all
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

      # POST /api/tournaments/:id/start
      def start
        @tournament = Tournament.find(params[:id])
        @tournament.start()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tournament not found' }, status: :not_found
      end

      # POST /api/tournaments/:id/cancel
      def cancel
        @tournament = Tournament.find(params[:id])
        @tournament.cancel()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tournament not found' }, status: :not_found
      end

      # POST /api/tournaments/:id/complete
      def complete
        @tournament = Tournament.find(params[:id])
        @tournament.complete()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tournament not found' }, status: :not_found
      end

      # POST /api/tournaments/:id/rounds
      def generate_round
        @tournament = Tournament.find(params[:id])
        @tournament.generate_round()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tournament not found' }, status: :not_found
      end

      # GET /api/tournaments/:id/prizes
      def calculate_prize_distribution
        @tournament = Tournament.find(params[:id])
        result = @tournament.calculate_prize_distribution()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tournament not found' }, status: :not_found
      end

      # POST /api/tournaments/:id/register
      def register_player
        @tournament = Tournament.find(params[:id])
        player_id = params[:player_id]
        deck_id = params[:deck_id]
        @tournament.register_player(player_id, deck_id)
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tournament not found' }, status: :not_found
      end

      # GET /api/tournaments/:id/full
      def is_full
        @tournament = Tournament.find(params[:id])
        result = @tournament.is_full()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tournament not found' }, status: :not_found
      end
      # PATCH /api/:id/transitions/draft-to-registration
      def transition_draft_to_registration
        unless current_user&.role.in?(["Admin", "Organizer"])
          render json: { error: 'Insufficient role for transition Draft -> Registration' }, status: :forbidden
          return
        end
        @tournament = Tournament.find(params[:id])
        @tournament.assert_transition!('registration')
        if @tournament.name.nil?
          render json: { error: 'name is required for Draft -> Registration' }, status: :unprocessable_content
          return
        end
        if @tournament.start_time.nil?
          render json: { error: 'start_time is required for Draft -> Registration' }, status: :unprocessable_content
          return
        end
        @tournament.update_columns(status: 'registration')
        @tournament.reload
        render json: @tournament
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tournament not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/registration-to-ongoing
      def transition_registration_to_ongoing
        unless current_user&.role.in?(["Admin", "Organizer"])
          render json: { error: 'Insufficient role for transition Registration -> Ongoing' }, status: :forbidden
          return
        end
        @tournament = Tournament.find(params[:id])
        @tournament.assert_transition!('ongoing')
        @tournament.update_columns(status: 'ongoing')
        @tournament.reload
        @tournament.start  # @after
        render json: @tournament
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tournament not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/registration-to-cancelled
      def transition_registration_to_cancelled
        unless current_user&.role.in?(["Admin", "Organizer"])
          render json: { error: 'Insufficient role for transition Registration -> Cancelled' }, status: :forbidden
          return
        end
        @tournament = Tournament.find(params[:id])
        @tournament.assert_transition!('cancelled')
        @tournament.update_columns(status: 'cancelled')
        @tournament.reload
        @tournament.cancel  # @after
        render json: @tournament
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tournament not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/ongoing-to-completed
      def transition_ongoing_to_completed
        unless current_user&.role.in?(["Admin", "Organizer"])
          render json: { error: 'Insufficient role for transition Ongoing -> Completed' }, status: :forbidden
          return
        end
        @tournament = Tournament.find(params[:id])
        @tournament.assert_transition!('completed')
        @tournament.update_columns(status: 'completed')
        @tournament.reload
        @tournament.complete  # @after
        @tournament.calculate_prize_distribution  # @after
        render json: @tournament
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tournament not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/ongoing-to-cancelled
      def transition_ongoing_to_cancelled
        unless current_user&.role.in?(["Admin"])
          render json: { error: 'Insufficient role for transition Ongoing -> Cancelled' }, status: :forbidden
          return
        end
        @tournament = Tournament.find(params[:id])
        @tournament.assert_transition!('cancelled')
        @tournament.update_columns(status: 'cancelled')
        @tournament.reload
        @tournament.cancel  # @after
        render json: @tournament
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tournament not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/completed-to-draft
      def transition_completed_to_draft
        render json: { error: 'Transition Completed -> Draft is not allowed' }, status: :conflict
        return
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Tournament not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/cancelled-to-draft
      def transition_cancelled_to_draft
        render json: { error: 'Transition Cancelled -> Draft is not allowed' }, status: :conflict
        return
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
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
        params.fetch(:tournament, params).permit(:public_id, :name, :description, :status, :bracket_data, :format, :tournament_type, :max_players, :entry_fee, :prize_pool, :start_time, :end_time, :is_online, :location, :rules_text, :created_at, :season_id, :organizer_id)
      end

      def tournament_update_params
        params.fetch(:tournament, params).permit(:public_id, :name, :description, :bracket_data, :format, :tournament_type, :max_players, :entry_fee, :prize_pool, :start_time, :end_time, :is_online, :location, :rules_text, :season_id, :organizer_id)
      end
    end
  end
end
