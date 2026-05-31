defmodule CardsProjectWeb.Players.AchievementControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "name" => "test",
    "description" => "test",
    "points" => 1,
    "is_hidden" => true,
    "rarity" => "Common"
  }

  describe "GET /api/achievements" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/achievements")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "GET /api/achievements?q=test" do
    test "returns 200 with search results", %{conn: conn} do
      conn = get(conn, "/api/achievements?q=test")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/achievements" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/achievements", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
    test "fails when points_positive violated", %{conn: conn} do
      params = Map.put(@valid_params, "points", 0)
      conn = post(conn, "/api/achievements", params)
      assert conn.status in [400, 422]
    end
  end

  describe "GET /api/achievements/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_achievement(@valid_params)
      conn = get(conn, "/api/achievements/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/achievements/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_achievement(@valid_params)
      conn = put(conn, "/api/achievements/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

end
