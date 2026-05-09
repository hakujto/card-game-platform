require 'rails_helper'

RSpec.describe "Api::Players::CraftingRecipes", type: :request do
  let(:valid_attributes) do
    {
        dust_cost: 1,
        is_available: true
    }
  end

  describe "GET /api/crafting_recipes" do
    it "returns 200" do
      get "/api/crafting_recipes"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/crafting_recipes" do
    context "with valid params" do
      it "returns 201" do
        post "/api/crafting_recipes", params: { crafting_recipe: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/crafting_recipes/:id" do
    let!(:craftingRecipe) { CraftingRecipe.create!(valid_attributes) }

    it "returns 200" do
      get "/api/crafting_recipes/#{craftingRecipe.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/crafting_recipes/:id" do
    let!(:craftingRecipe) { CraftingRecipe.create!(valid_attributes) }

    it "returns 200" do
      patch "/api/crafting_recipes/#{craftingRecipe.id}",
            params: { crafting_recipe: { dust_cost: 1 } },
            as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/crafting_recipes/:id" do
    let!(:craftingRecipe) { CraftingRecipe.create!(valid_attributes) }

    it "returns 204" do
      delete "/api/crafting_recipes/#{craftingRecipe.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
