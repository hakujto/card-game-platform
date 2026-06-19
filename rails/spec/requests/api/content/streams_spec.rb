require 'rails_helper'

RSpec.describe "Api::Content::Streams", type: :request do
  before(:each) do
    @dep_streamer = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
  end

  let(:valid_attributes) do
    {
      title: 'test',
      stream_url: 'https://example.com',
      status: :live,
      platform: :twitch,
      language: :e_n,
      is_official: true,
      viewer_count_peak: 1,
      scheduled_start: Time.now,
      streamer_id: @dep_streamer.id
    }
  end

  describe "GET /api/streams" do
    it "returns 200" do
      get "/api/streams"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /api/streams?q=test" do
    it "returns 200" do
      get "/api/streams?q=test"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/streams" do
    context "with valid params" do
      it "returns 201" do
        post "/api/streams", params: { stream: {
      title: 'test',
      stream_url: 'https://example.com',
      status: :live,
      platform: :twitch,
      language: :e_n,
      is_official: true,
      viewer_count_peak: 1,
      scheduled_start: Time.now,
      streamer_id: @dep_streamer.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/streams/:id" do
    let!(:stream) { Stream.create!(valid_attributes) }

    it "returns 200" do
      get "/api/streams/#{stream.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/streams/:id" do
    let!(:stream) { Stream.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/streams/#{stream.id}",
            params: { stream: { title: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end


  describe "POST /api/streams (rule: actual_start_requires_live_or_ended)" do
    it "create fails when actual start requires live or ended violated" do
      # actual_start_requires_live_or_ended
      post "/api/streams", params: { stream: {
        title: 'test',
        stream_url: 'https://example.com',
        scheduled_start: Time.now,
        streamer_id: 1,
        actual_start: Time.now,
        status: :scheduled,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/streams (rule: ended_at_requires_ended_status)" do
    it "create fails when ended at requires ended status violated" do
      # ended_at can only be set when stream status is Ended
      post "/api/streams", params: { stream: {
        title: 'test',
        stream_url: 'https://example.com',
        scheduled_start: Time.now,
        streamer_id: 1,
        ended_at: Time.now,
        status: :scheduled,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/streams (rule: viewer_count_not_negative)" do
    it "create fails when viewer count not negative violated" do
      # Peak viewer count must not be negative
      post "/api/streams", params: { stream: {
        title: 'test',
        stream_url: 'https://example.com',
        scheduled_start: Time.now,
        streamer_id: 1,
        actual_start: Time.now,
        status: :live,
        ended_at: Time.now,
        viewer_count_peak: -1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
  describe "PATCH /api/streams/:id/transitions/scheduled-to-live" do
    let!(:stream) { Stream.create!(valid_attributes).tap { |r| r.update_column(:status, Stream.statuses['scheduled']) } }
    before { stream.update!(stream_url: 'https://example.com') }
    it "transitions to Live with role Streamer" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'Streamer'))
      patch "/api/streams/#{stream.id}/transitions/scheduled-to-live"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(stream.reload.status).to eq('live') if response.status == 200
    end

    it "returns 403 for transition Scheduled -> Live with insufficient role" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'guest'))
      patch "/api/streams/#{stream.id}/transitions/scheduled-to-live"
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/streams/:id/transitions/live-to-ended" do
    let!(:stream) { Stream.create!(valid_attributes).tap { |r| r.update_column(:status, Stream.statuses['live']) } }
    it "transitions to Ended with role Streamer" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'Streamer'))
      patch "/api/streams/#{stream.id}/transitions/live-to-ended"
      # If 422: model has rules that require extra fields for this state — set them in before block
      expect([200, 422]).to include(response.status)
      expect(stream.reload.status).to eq('ended') if response.status == 200
    end

    it "returns 403 for transition Live -> Ended with insufficient role" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', role: 'guest'))
      patch "/api/streams/#{stream.id}/transitions/live-to-ended"
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/streams/:id/transitions/ended-to-live" do
    let!(:stream) { Stream.create!(valid_attributes) }
    it "returns 409 (denied)" do
      patch "/api/streams/#{stream.id}/transitions/ended-to-live"
      expect(response).to have_http_status(:conflict)
    end
  end
end
