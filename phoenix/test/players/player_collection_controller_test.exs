defmodule CardsProjectWeb.Players.PlayerCollectionControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "quantity" => 0,
    "foil" => true,
    "acquired_at" => ~N[2024-01-01 00:00:00],
    "condition" => "Mint",
    "acquired_via" => "Purchase"
  }

  describe "GET /api/player_collections" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/player_collections")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/player_collections" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/player_collections", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/player_collections/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_player_collection(@valid_params)
      conn = get(conn, "/api/player_collections/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/player_collections/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_player_collection(@valid_params)
      conn = put(conn, "/api/player_collections/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/player_collections/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_player_collection(@valid_params)
      conn = delete(conn, "/api/player_collections/#{record.id}")
      assert response(conn, 204)
    end
  end
end
