defmodule CardsProjectWeb.Tournaments.MatchControllerTest do
  use ExUnit.Case, async: true
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "status" => "test",
    "player1_wins" => 0,
    "player2_wins" => 0,
    "status" => "Pending"
  }

  describe "GET /api/matches" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/matches")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/matches" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/matches", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/matches/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_match(@valid_params)
      conn = get(conn, "/api/matches/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/matches/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_match(@valid_params)
      conn = put(conn, "/api/matches/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/matches/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_match(@valid_params)
      conn = delete(conn, "/api/matches/#{record.id}")
      assert response(conn, 204)
    end
  end
end
