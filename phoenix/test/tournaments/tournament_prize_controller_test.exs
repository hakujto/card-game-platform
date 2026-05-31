defmodule CardsProjectWeb.Tournaments.TournamentPrizeControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "placement_from" => 1,
    "placement_to" => 1,
    "amount" => 0,
    "season_points" => 0,
    "prize_type" => "Currency"
  }

  describe "GET /api/tournament_prizes" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/tournament_prizes")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/tournament_prizes" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/tournament_prizes", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
    test "fails when placement_range_valid violated", %{conn: conn} do
      params = Map.put(@valid_params, "placement_to", NaN)
      conn = post(conn, "/api/tournament_prizes", params)
      assert conn.status in [400, 422]
    end
    test "fails when placement_from_positive violated", %{conn: conn} do
      params = Map.put(@valid_params, "placement_from", 0)
      conn = post(conn, "/api/tournament_prizes", params)
      assert conn.status in [400, 422]
    end
    test "fails when amount_not_negative violated", %{conn: conn} do
      params = Map.put(@valid_params, "amount", -1)
      conn = post(conn, "/api/tournament_prizes", params)
      assert conn.status in [400, 422]
    end
  end

  describe "GET /api/tournament_prizes/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament_prize(@valid_params)
      conn = get(conn, "/api/tournament_prizes/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/tournament_prizes/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament_prize(@valid_params)
      conn = put(conn, "/api/tournament_prizes/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/tournament_prizes/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament_prize(@valid_params)
      conn = delete(conn, "/api/tournament_prizes/#{record.id}")
      assert response(conn, 204)
    end
  end

end
