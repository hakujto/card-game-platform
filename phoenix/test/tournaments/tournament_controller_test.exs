defmodule CardsProjectWeb.Tournaments.TournamentControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "name" => "test",
    "max_players" => 0,
    "entry_fee" => "0.00",
    "prize_pool" => "0.00",
    "start_time" => ~N[2024-01-01 00:00:00],
    "is_online" => true,
    "created_at" => ~N[2024-01-01 00:00:00],
    "format" => "Standard",
    "tournament_type" => "Swiss",
    "status" => "Draft"
  }

  describe "GET /api/tournaments" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/tournaments")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/tournaments" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/tournaments", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/tournaments/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament(@valid_params)
      conn = get(conn, "/api/tournaments/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/tournaments/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament(@valid_params)
      conn = put(conn, "/api/tournaments/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/tournaments/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament(@valid_params)
      conn = delete(conn, "/api/tournaments/#{record.id}")
      assert response(conn, 204)
    end
  end
end
