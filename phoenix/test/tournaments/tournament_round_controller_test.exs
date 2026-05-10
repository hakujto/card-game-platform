defmodule CardsProjectWeb.Tournaments.TournamentRoundControllerTest do
  use ExUnit.Case, async: true
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "round_number" => 0,
    "status" => "test",
    "time_limit_minutes" => 0,
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
  end

  describe "GET /api/tournament_rounds/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament_round(@valid_params)
      conn = get(conn, "/api/tournament_rounds/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/tournament_rounds/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament_round(@valid_params)
      conn = put(conn, "/api/tournament_rounds/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/tournament_rounds/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament_round(@valid_params)
      conn = delete(conn, "/api/tournament_rounds/#{record.id}")
      assert response(conn, 204)
    end
  end
end
