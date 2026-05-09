require 'rails_helper'

RSpec.describe "Api::Tournaments::TournamentRegistrations", type: :request do
  let(:valid_attributes) do
    {
        points_earned: 1,
        registered_at: Time.now
    }
  end

  describe "GET /api/tournament_registrations" do
    it "returns 200" do
      get "/api/tournament_registrations"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/tournament_registrations" do
    context "with valid params" do
      it "returns 201" do
        post "/api/tournament_registrations", params: { tournament_registration: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/tournament_registrations/:id" do
    let!(:tournamentRegistration) { TournamentRegistration.create!(valid_attributes) }

    it "returns 200" do
      get "/api/tournament_registrations/#{tournamentRegistration.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/tournament_registrations/:id" do
    let!(:tournamentRegistration) { TournamentRegistration.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/tournament_registrations/#{tournamentRegistration.id}",
            params: { tournament_registration: { status: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/tournament_registrations/:id" do
    let!(:tournamentRegistration) { TournamentRegistration.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/tournament_registrations/#{tournamentRegistration.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
