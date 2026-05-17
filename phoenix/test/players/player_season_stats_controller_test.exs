defmodule CardsProjectWeb.Players.PlayerSeasonStatsControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "wins" => 0,
    "losses" => 0,
    "draws" => 0,
    "tournament_wins" => 0,
    "season_points" => 0
  }

  describe "GET /api/player_season_statses" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/player_season_statses")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/player_season_statses" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/player_season_statses", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/player_season_statses/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_player_season_stats(@valid_params)
      conn = get(conn, "/api/player_season_statses/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/player_season_statses/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_player_season_stats(@valid_params)
      conn = put(conn, "/api/player_season_statses/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/player_season_statses/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_player_season_stats(@valid_params)
      conn = delete(conn, "/api/player_season_statses/#{record.id}")
      assert response(conn, 204)
    end
  end
end
