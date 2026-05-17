require 'rails_helper'

RSpec.describe "Api::Players::CraftingRecipes", type: :request do
  before(:each) do
    @aux_card_set = CardSet.create!({ name: 'test', code: 'test', release_date: Date.today, set_type: :core, total_cards: 1 })
    @dep_result_card = Card.create!({ name: 'test', card_type: :spell, rarity: :common, mana_cost: 1, mana_colors: :white, description: 'test', legal_formats: :standard, is_banned: false, is_restricted: false, power_level: 1, set_id: @aux_card_set.id })
  end

  let(:valid_attributes) do
    {
      dust_cost: 1,
      is_available: true,
      result_card_id: @dep_result_card.id
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
        post "/api/crafting_recipes", params: { crafting_recipe: {
      dust_cost: 1,
      is_available: true,
      result_card_id: @dep_result_card.id
        } }, as: :json
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
            params: { crafting_recipe: { is_available: true } },
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

  describe "POST /api/crafting_recipes (rule: dust_cost_positive)" do
    it "create fails when dust cost positive violated" do
      # Crafting recipe must have a dust cost greater than zero
      post "/api/crafting_recipes", params: { crafting_recipe: {
        result_card_id: 1,
        dust_cost: 0,
      } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
