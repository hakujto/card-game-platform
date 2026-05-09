require 'rails_helper'

RSpec.describe "Api::Players::CraftingIngredients", type: :request do
  let(:valid_attributes) do
    {
        quantity: 1
    }
  end

  describe "GET /api/crafting_ingredients" do
    it "returns 200" do
      get "/api/crafting_ingredients"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/crafting_ingredients" do
    context "with valid params" do
      it "returns 201" do
        post "/api/crafting_ingredients", params: { crafting_ingredient: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/crafting_ingredients/:id" do
    let!(:craftingIngredient) { CraftingIngredient.create!(valid_attributes) }

    it "returns 200" do
      get "/api/crafting_ingredients/#{craftingIngredient.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/crafting_ingredients/:id" do
    let!(:craftingIngredient) { CraftingIngredient.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/crafting_ingredients/#{craftingIngredient.id}",
            params: { crafting_ingredient: { quantity: 1 } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/crafting_ingredients/:id" do
    let!(:craftingIngredient) { CraftingIngredient.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/crafting_ingredients/#{craftingIngredient.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
