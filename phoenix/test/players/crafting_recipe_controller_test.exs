defmodule CardsProjectWeb.Players.CraftingRecipeControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "dust_cost" => 1,
    "is_available" => true
  }

  describe "GET /api/crafting_recipes" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/crafting_recipes")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/crafting_recipes" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/crafting_recipes", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
    test "fails when dust_cost_positive violated", %{conn: conn} do
      params = Map.put(@valid_params, "dust_cost", 0)
      conn = post(conn, "/api/crafting_recipes", params)
      assert conn.status in [400, 422]
    end
  end

  describe "GET /api/crafting_recipes/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_crafting_recipe(@valid_params)
      conn = get(conn, "/api/crafting_recipes/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/crafting_recipes/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_crafting_recipe(@valid_params)
      conn = put(conn, "/api/crafting_recipes/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

end
