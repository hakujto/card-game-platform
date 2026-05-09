require 'rails_helper'

RSpec.describe "Api::Tournaments::Tournaments", type: :request do
  let(:valid_attributes) do
    {
        name: 'test',
        max_players: 1,
        entry_fee: '0.00',
        prize_pool: '0.00',
        start_time: Time.now,
        is_online: true,
        created_at: Time.now
    }
  end

  describe "GET /api/tournaments" do
    it "returns 200" do
      get "/api/tournaments"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/tournaments" do
    context "with valid params" do
      it "returns 201" do
        post "/api/tournaments", params: { tournament: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/tournaments/:id" do
    let!(:tournament) { Tournament.create!(valid_attributes) }

    it "returns 200" do
      get "/api/tournaments/#{tournament.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/tournaments/:id" do
    let!(:tournament) { Tournament.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/tournaments/#{tournament.id}",
            params: { tournament: { name: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/tournaments/:id" do
    let!(:tournament) { Tournament.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/tournaments/#{tournament.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
