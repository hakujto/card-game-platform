defmodule CardsProjectWeb.Players.PlayerControllerTest do
  use ExUnit.Case, async: true
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "display_name" => "test",
    "rank" => "test",
    "rating" => 0,
    "peak_rating" => 0,
    "is_verified" => true,
    "created_at" => ~N[2024-01-01 00:00:00],
    "rank" => "Bronze",
    "preferred_format" => "Standard"
  }

  describe "GET /api/players" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/players")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/players" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/players", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/players/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_player(@valid_params)
      conn = get(conn, "/api/players/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/players/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_player(@valid_params)
      conn = put(conn, "/api/players/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/players/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_player(@valid_params)
      conn = delete(conn, "/api/players/#{record.id}")
      assert response(conn, 204)
    end
  end
end
