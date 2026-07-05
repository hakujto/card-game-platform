module Api
  module Marketplace
    class TradeDisputesController < ApplicationController
      before_action :set_tradeDispute, only: [:show]

      # GET /api/trade_disputes
      def index
        @trade_disputes = TradeDispute.all
        render json: @trade_disputes
      end

      # POST /api/trade_disputes
      def create
        @tradeDispute = TradeDispute.new(trade_dispute_params)
        if @tradeDispute.save
          render json: @tradeDispute, status: :created
        else
          render json: { errors: @tradeDispute.errors }, status: :unprocessable_content
        end
      end

      # GET /api/trade_disputes/:id
      def show
        render json: @tradeDispute
      end

      # POST /api/trade_disputes/:id/escalate
      def escalate
        @tradeDispute = TradeDispute.find(params[:id])
        @tradeDispute.escalate()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeDispute not found' }, status: :not_found
      end

      # POST /api/trade_disputes/:id/resolve
      def resolve
        unless current_user&.role.in?(["admin", "moderator"])
          render json: { error: 'Insufficient role for resolve' }, status: :forbidden
          return
        end
        @tradeDispute = TradeDispute.find(params[:id])
        resolution_text = params[:resolution_text]
        @tradeDispute.resolve(resolution_text)
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeDispute not found' }, status: :not_found
      end

      # POST /api/trade_disputes/:id/close
      def close_resolved
        @tradeDispute = TradeDispute.find(params[:id])
        @tradeDispute.close_resolved()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeDispute not found' }, status: :not_found
      end

      # POST /api/trade_disputes/:id/review
      def review
        @tradeDispute = TradeDispute.find(params[:id])
        @tradeDispute.review()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeDispute not found' }, status: :not_found
      end
      # PATCH /api/:id/transitions/open-to-underreview
      def transition_open_to_underreview
        unless current_user&.role.in?(["Admin", "Moderator"])
          render json: { error: 'Insufficient role for transition Open -> UnderReview' }, status: :forbidden
          return
        end
        @tradeDispute = TradeDispute.find(params[:id])
        @tradeDispute.assert_transition!('under_review')
        @tradeDispute.update_columns(status: 'under_review')
        @tradeDispute.reload
        @tradeDispute.review  # @after
        render json: @tradeDispute
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeDispute not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/underreview-to-resolved
      def transition_underreview_to_resolved
        unless current_user&.role.in?(["Admin", "Moderator"])
          render json: { error: 'Insufficient role for transition UnderReview -> Resolved' }, status: :forbidden
          return
        end
        @tradeDispute = TradeDispute.find(params[:id])
        @tradeDispute.assert_transition!('resolved')
        if @tradeDispute.resolution.nil?
          render json: { error: 'resolution is required for UnderReview -> Resolved' }, status: :unprocessable_content
          return
        end
        @tradeDispute.update_columns(status: 'resolved')
        @tradeDispute.reload
        @tradeDispute.close_resolved  # @after
        render json: @tradeDispute
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeDispute not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/underreview-to-escalated
      def transition_underreview_to_escalated
        unless current_user&.role.in?(["Admin"])
          render json: { error: 'Insufficient role for transition UnderReview -> Escalated' }, status: :forbidden
          return
        end
        @tradeDispute = TradeDispute.find(params[:id])
        @tradeDispute.assert_transition!('escalated')
        @tradeDispute.update_columns(status: 'escalated')
        @tradeDispute.reload
        @tradeDispute.escalate  # @after
        render json: @tradeDispute
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeDispute not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/escalated-to-resolved
      def transition_escalated_to_resolved
        unless current_user&.role.in?(["Admin"])
          render json: { error: 'Insufficient role for transition Escalated -> Resolved' }, status: :forbidden
          return
        end
        @tradeDispute = TradeDispute.find(params[:id])
        @tradeDispute.assert_transition!('resolved')
        if @tradeDispute.resolution.nil?
          render json: { error: 'resolution is required for Escalated -> Resolved' }, status: :unprocessable_content
          return
        end
        @tradeDispute.update_columns(status: 'resolved')
        @tradeDispute.reload
        @tradeDispute.close_resolved  # @after
        render json: @tradeDispute
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeDispute not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/resolved-to-open
      def transition_resolved_to_open
        render json: { error: 'Transition Resolved -> Open is not allowed' }, status: :conflict
        return
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeDispute not found' }, status: :not_found
      end

      private

      def set_tradeDispute
        @tradeDispute = TradeDispute.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TradeDispute not found' }, status: :not_found
      end

      def trade_dispute_params
        params.fetch(:trade_dispute, params).permit(:status, :reason, :description, :resolution, :opened_at, :resolved_at, :transaction_id, :opened_by_id, :resolved_by_id)
      end

      def trade_dispute_update_params
        params.fetch(:trade_dispute, params).permit(:status, :reason, :description, :resolution, :opened_at, :resolved_at, :transaction_id, :opened_by_id, :resolved_by_id)
      end
    end
  end
end
