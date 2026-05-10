defmodule CardsProjectWeb.Tournaments.TournamentPrizeControllerTest do
  use ExUnit.Case, async: true
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "placement_from" => 0,
    "placement_to" => 0,
    "prize_type" => "test",
    "amount" => "0.00",
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
