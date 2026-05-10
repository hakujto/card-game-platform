defmodule CardsProjectWeb.Players.PlayerAchievementControllerTest do
  use ExUnit.Case, async: true
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "earned_at" => ~N[2024-01-01 00:00:00],
    "progress" => 0,
    "is_completed" => true
  }

  describe "GET /api/player_achievements" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/player_achievements")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/player_achievements" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/player_achievements", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/player_achievements/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_player_achievement(@valid_params)
      conn = get(conn, "/api/player_achievements/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/player_achievements/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_player_achievement(@valid_params)
      conn = put(conn, "/api/player_achievements/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/player_achievements/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_player_achievement(@valid_params)
      conn = delete(conn, "/api/player_achievements/#{record.id}")
      assert response(conn, 204)
    end
  end
end
