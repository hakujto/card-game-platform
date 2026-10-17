require "spec"
require "http/client"
require "json"

describe "CraftingRecipe API" do
  it "lists crafting_recipes" do
    response = HTTP::Client.get("http://localhost:3000/api/crafting_recipes")
    response.status_code.should eq 200
  end

  it "creates a crafting_recipe" do
    body = {"dust_cost": 1, "is_available": true, "result_card_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/crafting_recipes",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a crafting_recipe" do
    response = HTTP::Client.get("http://localhost:3000/api/crafting_recipes/1")
    [200, 404].should contain response.status_code
  end

  it "updates a crafting_recipe" do
    body = {"dust_cost": 1}.to_json
    response = HTTP::Client.patch(
      "http://localhost:3000/api/crafting_recipes/1",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    [200, 404].should contain response.status_code
  end

end
