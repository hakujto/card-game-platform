require 'rails_helper'

RSpec.describe "Api::Players::CraftingIngredients", type: :request do
  before(:each) do
    @aux_card_set = CardSet.create!({ name: 'test', code: 'test', release_date: Date.today, set_type: :core, total_cards: 1 })
    @aux_card = Card.create!({ name: 'test', card_type: :spell, rarity: :common, mana_cost: 1, mana_colors: :white, description: 'test', legal_formats: :standard, is_banned: false, is_restricted: false, power_level: 1, set_id: @aux_card_set.id })
    @dep_recipe = CraftingRecipe.create!({ dust_cost: 1, is_available: true, result_card_id: @aux_card.id })
  end

  let(:valid_attributes) do
    {
      quantity: 1,
      recipe_id: @dep_recipe.id,
      card_id: @aux_card.id
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
        post "/api/crafting_ingredients", params: { crafting_ingredient: {
      quantity: 1,
      recipe_id: @dep_recipe.id,
      card_id: @aux_card.id
        } }, as: :json
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
