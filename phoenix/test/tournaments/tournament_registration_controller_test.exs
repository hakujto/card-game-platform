defmodule CardsProjectWeb.Tournaments.TournamentRegistrationControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "points_earned" => 0,
    "registered_at" => ~N[2024-01-01 00:00:00],
    "status" => "Registered"
  }

  describe "GET /api/tournament_registrations" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/tournament_registrations")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/tournament_registrations" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/tournament_registrations", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
    test "fails when points_earned_not_negative violated", %{conn: conn} do
      params = Map.put(@valid_params, "points_earned", -1)
      conn = post(conn, "/api/tournament_registrations", params)
      assert conn.status in [400, 422]
    end
  end

  describe "GET /api/tournament_registrations/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament_registration(@valid_params)
      conn = get(conn, "/api/tournament_registrations/#{record.id}")
      assert json_response(conn, 200)
    end
  end

end
