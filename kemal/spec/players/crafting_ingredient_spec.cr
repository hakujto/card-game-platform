require "spec"
require "http/client"
require "json"

describe "CraftingIngredient API" do
  it "lists crafting_ingredients" do
    response = HTTP::Client.get("http://localhost:3000/api/crafting_ingredients")
    response.status_code.should eq 200
  end

  it "creates a crafting_ingredient" do
    body = {"quantity": 1, "recipe_id": 1, "card_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/crafting_ingredients",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a crafting_ingredient" do
    response = HTTP::Client.get("http://localhost:3000/api/crafting_ingredients/1")
    [200, 404].should contain response.status_code
  end

  it "deletes a crafting_ingredient" do
    response = HTTP::Client.delete("http://localhost:3000/api/crafting_ingredients/1")
    [204, 404].should contain response.status_code
  end

end
