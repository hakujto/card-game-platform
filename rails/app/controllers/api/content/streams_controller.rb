module Api
  module Content
    class StreamsController < ApplicationController
      before_action :set_stream, only: [:show, :update]

      # GET /api/streams?q=...
      def index
        q = params[:q]
        @streams = q.present? ? Stream.where(Stream.arel_table[:title].matches("%#{q}%")) : Stream.all
        render json: @streams
      end

      # POST /api/streams
      def create
        @stream = Stream.new(stream_params)
        if @stream.save
          render json: @stream, status: :created
        else
          render json: { errors: @stream.errors }, status: :unprocessable_content
        end
      end

      # GET /api/streams/:id
      def show
        render json: @stream
      end

      # PATCH/PUT /api/streams/:id
      def update
        if @stream.update(stream_update_params)
          render json: @stream
        else
          render json: { errors: @stream.errors }, status: :unprocessable_content
        end
      end

      # POST /api/streams/:id/live
      def go_live
        @stream = Stream.find(params[:id])
        @stream.go_live()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Stream not found' }, status: :not_found
      end

      # POST /api/streams/:id/end
      def end
        @stream = Stream.find(params[:id])
        @stream.end()
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Stream not found' }, status: :not_found
      end

      # PATCH /api/streams/:id/viewers
      def update_viewer_peak
        @stream = Stream.find(params[:id])
        count = params[:count]
        @stream.update_viewer_peak(count)
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Stream not found' }, status: :not_found
      end

      # GET /api/streams/:id/duration
      def duration_minutes
        @stream = Stream.find(params[:id])
        result = @stream.duration_minutes()
        render json: { result: result }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Stream not found' }, status: :not_found
      end
      # PATCH /api/:id/transitions/scheduled-to-live
      def transition_scheduled_to_live
        unless current_user&.role.in?(["Streamer", "Admin"])
          render json: { error: 'Insufficient role for transition Scheduled -> Live' }, status: :forbidden
          return
        end
        @stream = Stream.find(params[:id])
        @stream.assert_transition!('live')
        if @stream.stream_url.nil?
          render json: { error: 'stream_url is required for Scheduled -> Live' }, status: :unprocessable_content
          return
        end
        @stream.update_columns(status: 'live')
        @stream.reload
        @stream.go_live  # @after
        render json: @stream
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Stream not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/live-to-ended
      def transition_live_to_ended
        unless current_user&.role.in?(["Streamer", "Admin"])
          render json: { error: 'Insufficient role for transition Live -> Ended' }, status: :forbidden
          return
        end
        @stream = Stream.find(params[:id])
        @stream.assert_transition!('ended')
        @stream.update_columns(status: 'ended')
        @stream.reload
        @stream.end  # @after
        render json: @stream
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Stream not found' }, status: :not_found
      end

      # PATCH /api/:id/transitions/ended-to-live
      def transition_ended_to_live
        render json: { error: 'Transition Ended -> Live is not allowed' }, status: :conflict
        return
      rescue ArgumentError => e
        render json: { error: e.message }, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Stream not found' }, status: :not_found
      end

      private

      def set_stream
        @stream = Stream.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Stream not found' }, status: :not_found
      end

      def stream_params
        params.fetch(:stream, params).permit(:title, :stream_url, :status, :platform, :language, :is_official, :viewer_count_peak, :scheduled_start, :actual_start, :ended_at, :vod_url, :tournament_id, :streamer_id)
      end

      def stream_update_params
        params.fetch(:stream, params).permit(:title, :stream_url, :status, :platform, :language, :is_official, :viewer_count_peak, :scheduled_start, :actual_start, :ended_at, :vod_url, :tournament_id, :streamer_id)
      end
    end
  end
end
