module Api
  module Content
    class StreamsController < ApplicationController
      before_action :set_stream, only: [:show, :update, :destroy]

      # GET /api/streams
      def index
        @streams = Stream.all
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

      # DELETE /api/streams/:id
      def destroy
        @stream.destroy
        head :no_content
      end

      # POST /api/streams/:id/live
      def go_live
        @stream = Stream.find(params[:id])
        @stream.go_live
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Stream not found' }, status: :not_found
      end

      # POST /api/streams/:id/end
      def end
        @stream = Stream.find(params[:id])
        @stream.end
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

      private

      def set_stream
        @stream = Stream.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Stream not found' }, status: :not_found
      end

      def stream_params
        params.fetch(:stream, params).permit(:title, :stream_url, :platform, :status, :viewer_count_peak, :scheduled_start, :actual_start, :ended_at, :vod_url, :tournament_id, :streamer_id)
      end

      def stream_update_params
        params.fetch(:stream, params).permit(:title, :stream_url, :platform, :status, :viewer_count_peak, :scheduled_start, :actual_start, :ended_at, :vod_url, :tournament_id, :streamer_id)
      end
    end
  end
end
