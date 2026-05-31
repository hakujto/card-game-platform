defmodule CardsProjectWeb.Tournaments.SeasonControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "name" => "test",
    "start_date" => ~D[2024-01-01],
    "end_date" => ~D[2024-12-31],
    "is_active" => true,
    "format" => "Standard"
  }

  describe "GET /api/seasons" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/seasons")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "GET /api/seasons?q=test" do
    test "returns 200 with search results", %{conn: conn} do
      conn = get(conn, "/api/seasons?q=test")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/seasons" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/seasons", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
    test "fails when end_date_after_start_date violated", %{conn: conn} do
      params = Map.put(@valid_params, "end_date", 0)
      conn = post(conn, "/api/seasons", params)
      assert conn.status in [400, 422]
    end
  end

  describe "GET /api/seasons/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_season(@valid_params)
      conn = get(conn, "/api/seasons/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/seasons/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_season(@valid_params)
      conn = put(conn, "/api/seasons/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

end
