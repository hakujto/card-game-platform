module Api
  module Marketplace
    class OrdersController < ApplicationController
      before_action :set_order, only: [:show]

      # GET /api/orders
      def index
        @orders = Order.all
        render json: @orders
      end

      # POST /api/orders
      def create
        @order = Order.new(order_params)
        if @order.save
          render json: @order, status: :created
        else
          render json: { errors: @order.errors }, status: :unprocessable_content
        end
      end

      # GET /api/orders/:id
      def show
        render json: @order
      end

      # DELETE /api/orders/:id/cancel
      def cancel
        @order = Order.find(params[:id])
        @order.cancel()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      # POST /api/orders/:id/pay
      def pay
        @order = Order.find(params[:id])
        unless @order.status == 'pending'
          render json: { error: 'Guard condition not met for pay' }, status: :unprocessable_entity
          return
        end
        payment_ref = params[:payment_ref]
        result = @order.pay(payment_ref)
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      # POST /api/orders/:id/process-payment
      def process_payment
        @order = Order.find(params[:id])
        result = @order.process_payment()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      # GET /api/orders/:id/total
      def calculate_total
        @order = Order.find(params[:id])
        result = @order.calculate_total()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      # PATCH /api/orders/:id/discount
      def apply_discount
        @order = Order.find(params[:id])
        percent = params[:percent]
        result = @order.apply_discount(percent)
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      # POST /api/orders/:id/refund
      def refund
        @order = Order.find(params[:id])
        @order.refund()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end
      # PATCH /api/:id/transitions/pending-to-paid
      def transition_pending_to_paid
        @order = Order.find(params[:id])
        @order.assert_transition!('paid')
        if @order.payment_method.nil?
          render json: { error: 'payment_method is required for Pending -> Paid' }, status: :unprocessable_content
          return
        end
        @order.status = 'paid'
        @order.process_payment  # @after
        if @order.save
          render json: @order
        else
          render json: { errors: @order.errors }, status: :unprocessable_content
        end
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/paid-to-processing
      def transition_paid_to_processing
        unless current_user&.role.in?(["Admin", "Staff"])
          render json: { error: 'Insufficient role for transition Paid -> Processing' }, status: :forbidden
          return
        end
        @order = Order.find(params[:id])
        @order.assert_transition!('processing')
        @order.status = 'processing'
        if @order.save
          render json: @order
        else
          render json: { errors: @order.errors }, status: :unprocessable_content
        end
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/processing-to-shipped
      def transition_processing_to_shipped
        unless current_user&.role.in?(["Admin", "Staff"])
          render json: { error: 'Insufficient role for transition Processing -> Shipped' }, status: :forbidden
          return
        end
        @order = Order.find(params[:id])
        @order.assert_transition!('shipped')
        if @order.tracking_number.nil?
          render json: { error: 'tracking_number is required for Processing -> Shipped' }, status: :unprocessable_content
          return
        end
        @order.status = 'shipped'
        @order.notify_shipped  # @after
        if @order.save
          render json: @order
        else
          render json: { errors: @order.errors }, status: :unprocessable_content
        end
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/shipped-to-completed
      def transition_shipped_to_completed
        unless current_user&.role.in?(["Admin", "Staff"])
          render json: { error: 'Insufficient role for transition Shipped -> Completed' }, status: :forbidden
          return
        end
        @order = Order.find(params[:id])
        @order.assert_transition!('completed')
        @order.status = 'completed'
        if @order.save
          render json: @order
        else
          render json: { errors: @order.errors }, status: :unprocessable_content
        end
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/pending-to-cancelled
      def transition_pending_to_cancelled
        @order = Order.find(params[:id])
        @order.assert_transition!('cancelled')
        @order.status = 'cancelled'
        @order.cancel  # @after
        if @order.save
          render json: @order
        else
          render json: { errors: @order.errors }, status: :unprocessable_content
        end
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/paid-to-cancelled
      def transition_paid_to_cancelled
        unless current_user&.role.in?(["Admin", "Staff"])
          render json: { error: 'Insufficient role for transition Paid -> Cancelled' }, status: :forbidden
          return
        end
        @order = Order.find(params[:id])
        @order.assert_transition!('cancelled')
        @order.status = 'cancelled'
        @order.cancel  # @after
        if @order.save
          render json: @order
        else
          render json: { errors: @order.errors }, status: :unprocessable_content
        end
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/completed-to-refunded
      def transition_completed_to_refunded
        unless current_user&.role.in?(["Admin"])
          render json: { error: 'Insufficient role for transition Completed -> Refunded' }, status: :forbidden
          return
        end
        @order = Order.find(params[:id])
        @order.assert_transition!('refunded')
        @order.status = 'refunded'
        @order.refund  # @after
        if @order.save
          render json: @order
        else
          render json: { errors: @order.errors }, status: :unprocessable_content
        end
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/refunded-to-completed
      def transition_refunded_to_completed
        render json: { error: 'Transition Refunded -> Completed is not allowed' }, status: :conflict
        return
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/completed-to-cancelled
      def transition_completed_to_cancelled
        render json: { error: 'Transition Completed -> Cancelled is not allowed' }, status: :conflict
        return
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      private

      def set_order
        @order = Order.find(params[:id])
        if @order.player_id != current_user&.id
          render json: { error: 'You do not own this resource.' }, status: :forbidden and return
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      def order_params
        params.fetch(:order, params).permit(:status, :total, :discount_applied, :currency, :payment_method, :payment_reference, :shipping_address, :tracking_number, :created_at, :paid_at, :shipped_at, :player_id, :coupon_id)
      end

      def order_update_params
        params.fetch(:order, params).permit(:status, :total, :discount_applied, :currency, :payment_method, :payment_reference, :shipping_address, :tracking_number, :created_at, :paid_at, :shipped_at, :player_id, :coupon_id)
      end
    end
  end
end
