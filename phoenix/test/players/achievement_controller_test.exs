defmodule CardsProjectWeb.Players.AchievementControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "name" => "test",
    "description" => "test",
    "points" => 0,
    "is_hidden" => true,
    "rarity" => "Common"
  }

  describe "GET /api/achievements" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/achievements")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/achievements" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/achievements", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
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

  describe "DELETE /api/achievements/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_achievement(@valid_params)
      conn = delete(conn, "/api/achievements/#{record.id}")
      assert response(conn, 204)
    end
  end
end
