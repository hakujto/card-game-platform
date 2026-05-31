defmodule CardsProjectWeb.Players.PlayerAchievementControllerTest do
  use ExUnit.Case, async: false
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

  describe "GET /api/player_achievements/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_player_achievement(@valid_params)
      conn = get(conn, "/api/player_achievements/#{record.id}")
      assert json_response(conn, 200)
    end
  end

end
