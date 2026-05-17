defmodule CardsProjectWeb.Tournaments.TournamentJudgeControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "role" => "HeadJudge"
  }

  describe "GET /api/tournament_judges" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/tournament_judges")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/tournament_judges" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/tournament_judges", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/tournament_judges/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament_judge(@valid_params)
      conn = get(conn, "/api/tournament_judges/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/tournament_judges/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament_judge(@valid_params)
      conn = put(conn, "/api/tournament_judges/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/tournament_judges/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament_judge(@valid_params)
      conn = delete(conn, "/api/tournament_judges/#{record.id}")
      assert response(conn, 204)
    end
  end
end
