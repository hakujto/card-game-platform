require 'rails_helper'

RSpec.describe "Api::Players::Friendships", type: :request do
  before(:each) do
    @owner = Player.create!({ public_id: SecureRandom.uuid, display_name: 'test2', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
    @owner_id = @owner.id
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', id: @owner_id))
    @dep_receiver = Player.create!({ public_id: SecureRandom.uuid, display_name: 'test', rank: :bronze, rating: 1, peak_rating: 1, is_verified: true, created_at: Time.now })
  end

  let(:valid_attributes) do
    {
      status: :pending,
      created_at: Time.now,
      receiver_id: @dep_receiver.id,
      requester_id: @owner_id
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
      receiver_id: @dep_receiver.id,
      requester_id: @owner_id
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

  describe "DELETE /api/friendships/:id" do
    let!(:friendship) { Friendship.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/friendships/#{friendship.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

end
