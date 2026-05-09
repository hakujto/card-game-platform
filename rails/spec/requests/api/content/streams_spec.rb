require 'rails_helper'

RSpec.describe "Api::Content::Streams", type: :request do
  let(:valid_attributes) do
    {
        title: 'test',
        stream_url: 'https://example.com',
        viewer_count_peak: 1,
        scheduled_start: Time.now
    }
  end

  describe "GET /api/streams" do
    it "returns 200" do
      get "/api/streams"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/streams" do
    context "with valid params" do
      it "returns 201" do
        post "/api/streams", params: { stream: valid_attributes }, as: :json
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

  describe "DELETE /api/streams/:id" do
    let!(:stream) { Stream.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/streams/#{stream.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
