defmodule CardsProjectWeb.Players.PlayerControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "display_name" => "test",
    "rating" => 0,
    "peak_rating" => 1,
    "is_verified" => true,
    "created_at" => ~N[2024-01-01 00:00:00],
    "rank" => "Bronze"
  }

  describe "GET /api/players" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/players")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "GET /api/players?q=test" do
    test "returns 200 with search results", %{conn: conn} do
      conn = get(conn, "/api/players?q=test")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/players" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/players", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
    test "fails when rating_range violated", %{conn: conn} do
      params = Map.put(@valid_params, "rating", 99991)
      conn = post(conn, "/api/players", params)
      assert conn.status in [400, 422]
    end
    test "fails when peak_rating_gte_rating violated", %{conn: conn} do
      params = Map.put(@valid_params, "peak_rating", NaN)
      conn = post(conn, "/api/players", params)
      assert conn.status in [400, 422]
    end
  end

  describe "GET /api/players/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_player(@valid_params)
      conn = get(conn, "/api/players/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/players/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_player(@valid_params)
      conn = put(conn, "/api/players/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

end
