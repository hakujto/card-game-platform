defmodule CardsProjectWeb.Tournaments.TournamentRoundControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "round_number" => 1,
    "time_limit_minutes" => 1,
    "status" => "Pending"
  }

  describe "GET /api/tournament_rounds" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/tournament_rounds")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/tournament_rounds" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/tournament_rounds", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
    test "fails when round_number_positive violated", %{conn: conn} do
      params = Map.put(@valid_params, "round_number", 0)
      conn = post(conn, "/api/tournament_rounds", params)
      assert conn.status in [400, 422]
    end
    test "fails when time_limit_positive violated", %{conn: conn} do
      params = Map.put(@valid_params, "time_limit_minutes", 0)
      conn = post(conn, "/api/tournament_rounds", params)
      assert conn.status in [400, 422]
    end
  end

  describe "GET /api/tournament_rounds/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament_round(@valid_params)
      conn = get(conn, "/api/tournament_rounds/#{record.id}")
      assert json_response(conn, 200)
    end
  end

end
