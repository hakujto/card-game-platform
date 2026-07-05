defmodule CardsProjectWeb.Players.PlayerCollectionControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "quantity" => 1,
    "foil" => true,
    "acquired_at" => ~N[2024-01-01 00:00:00],
    "condition" => "Mint",
    "acquired_via" => "Purchase"
  }

  setup %{conn: conn} do
    {:ok, owner} = CardsProject.Players.create_player(%{"public_id" => "00000000-0000-0000-0000-000000000001", "display_name" => "test", "rank" => "Bronze", "rating" => 0, "peak_rating" => 0, "is_verified" => true, "created_at" => ~N[2024-01-01 00:00:00]})
    valid_params = Map.put(@valid_params, "player_id", owner.id)
    conn = assign(conn, :current_user, %{id: owner.id})
    {:ok, conn: conn, owner: owner, valid_params: valid_params}
  end

  describe "GET /api/player_collections" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/player_collections")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/player_collections" do
    test "creates record and returns 201", %{conn: conn, valid_params: valid_params} do
      conn = post(conn, "/api/player_collections", valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
    test "fails when quantity_positive violated", %{conn: conn, valid_params: valid_params} do
      params = Map.put(valid_params, "quantity", 0)
      conn = post(conn, "/api/player_collections", params)
      assert conn.status in [400, 422]
    end
  end

  describe "GET /api/player_collections/:id" do
    test "returns 200 for existing record", %{conn: conn, valid_params: valid_params} do
      {:ok, record} = CardsProject.Players.create_player_collection(valid_params)
      conn = get(conn, "/api/player_collections/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/player_collections/:id" do
    test "updates and returns 200", %{conn: conn, valid_params: valid_params} do
      {:ok, record} = CardsProject.Players.create_player_collection(valid_params)
      conn = put(conn, "/api/player_collections/#{record.id}", valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/player_collections/:id" do
    test "deletes and returns 204", %{conn: conn, valid_params: valid_params} do
      {:ok, record} = CardsProject.Players.create_player_collection(valid_params)
      conn = delete(conn, "/api/player_collections/#{record.id}")
      assert response(conn, 204)
    end
  end

end
