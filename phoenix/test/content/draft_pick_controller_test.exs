defmodule CardsProjectWeb.Content.DraftPickControllerTest do
  use ExUnit.Case, async: true
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "pick_number" => 0,
    "pack_number" => 0,
    "picked_at" => ~N[2024-01-01 00:00:00]
  }

  describe "GET /api/draft_picks" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/draft_picks")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/draft_picks" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/draft_picks", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/draft_picks/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_draft_pick(@valid_params)
      conn = get(conn, "/api/draft_picks/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/draft_picks/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_draft_pick(@valid_params)
      conn = put(conn, "/api/draft_picks/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/draft_picks/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_draft_pick(@valid_params)
      conn = delete(conn, "/api/draft_picks/#{record.id}")
      assert response(conn, 204)
    end
  end
end
