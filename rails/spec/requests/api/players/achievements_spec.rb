require 'rails_helper'

RSpec.describe "Api::Players::Achievements", type: :request do
  let(:valid_attributes) do
    {
        name: 'test',
        description: 'test',
        points: 1,
        is_hidden: true
    }
  end

  describe "GET /api/achievements" do
    it "returns 200" do
      get "/api/achievements"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/achievements" do
    context "with valid params" do
      it "returns 201" do
        post "/api/achievements", params: { achievement: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/achievements/:id" do
    let!(:achievement) { Achievement.create!(valid_attributes) }

    it "returns 200" do
      get "/api/achievements/#{achievement.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/achievements/:id" do
    let!(:achievement) { Achievement.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/achievements/#{achievement.id}",
            params: { achievement: { name: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/achievements/:id" do
    let!(:achievement) { Achievement.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/achievements/#{achievement.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
