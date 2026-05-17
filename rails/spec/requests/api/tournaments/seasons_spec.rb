require 'rails_helper'

RSpec.describe "Api::Tournaments::Seasons", type: :request do
  let(:valid_attributes) do
    {
      name: 'test',
      start_date: Date.today,
      end_date: Date.today + 1,
      format: :standard,
      is_active: true
    }
  end

  describe "GET /api/seasons" do
    it "returns 200" do
      get "/api/seasons"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/seasons" do
    context "with valid params" do
      it "returns 201" do
        post "/api/seasons", params: { season: {
      name: 'test',
      start_date: Date.today,
      end_date: Date.today + 1,
      format: :standard,
      is_active: true
        } }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/seasons/:id" do
    let!(:season) { Season.create!(valid_attributes) }

    it "returns 200" do
      get "/api/seasons/#{season.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/seasons/:id" do
    let!(:season) { Season.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/seasons/#{season.id}",
            params: { season: { name: 'test' } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/seasons/:id" do
    let!(:season) { Season.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/seasons/#{season.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/seasons (rule: end_date_after_start_date)" do
    it "create fails when end date after start date violated" do
      # Season end date must be after start date
      post "/api/seasons", params: { season: {
        name: 'test',
        start_date: Date.today,
        end_date: Date.today - 1,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
