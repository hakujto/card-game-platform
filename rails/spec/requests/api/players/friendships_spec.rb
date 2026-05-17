require 'rails_helper'

RSpec.describe "Api::Players::Friendships", type: :request do
  before(:each) do
    @dep_requester = Player.create!({ display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
  end

  let(:valid_attributes) do
    {
      status: :pending,
      created_at: Time.now,
      requester_id: @dep_requester.id,
      receiver_id: @dep_requester.id
    }
  end

  describe "GET /api/friendships" do
    it "returns 200" do
      get "/api/friendships"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/friendships" do
    context "with valid params" do
      it "returns 201" do
        post "/api/friendships", params: { friendship: {
      status: :pending,
      created_at: Time.now,
      requester_id: @dep_requester.id,
      receiver_id: @dep_requester.id
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/friendships/:id" do
    let!(:friendship) { Friendship.create!(valid_attributes) }

    it "returns 200" do
      get "/api/friendships/#{friendship.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/friendships/:id" do
    let!(:friendship) { Friendship.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/friendships/#{friendship.id}",
            params: { friendship: { status: :pending } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/friendships/:id" do
    let!(:friendship) { Friendship.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/friendships/#{friendship.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
