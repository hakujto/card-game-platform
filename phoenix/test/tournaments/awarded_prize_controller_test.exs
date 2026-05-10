defmodule CardsProjectWeb.Tournaments.AwardedPrizeControllerTest do
  use ExUnit.Case, async: true
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "final_placement" => 0,
    "awarded_at" => ~N[2024-01-01 00:00:00],
    "claimed" => true
  }

  describe "GET /api/awarded_prizes" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/awarded_prizes")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/awarded_prizes" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/awarded_prizes", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/awarded_prizes/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_awarded_prize(@valid_params)
      conn = get(conn, "/api/awarded_prizes/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/awarded_prizes/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_awarded_prize(@valid_params)
      conn = put(conn, "/api/awarded_prizes/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/awarded_prizes/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_awarded_prize(@valid_params)
      conn = delete(conn, "/api/awarded_prizes/#{record.id}")
      assert response(conn, 204)
    end
  end
end
