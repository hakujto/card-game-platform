defmodule CardsProjectWeb.Players.CraftingIngredientControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "quantity" => 0
  }

  describe "GET /api/crafting_ingredients" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/crafting_ingredients")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/crafting_ingredients" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/crafting_ingredients", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/crafting_ingredients/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_crafting_ingredient(@valid_params)
      conn = get(conn, "/api/crafting_ingredients/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/crafting_ingredients/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_crafting_ingredient(@valid_params)
      conn = put(conn, "/api/crafting_ingredients/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/crafting_ingredients/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_crafting_ingredient(@valid_params)
      conn = delete(conn, "/api/crafting_ingredients/#{record.id}")
      assert response(conn, 204)
    end
  end
end
