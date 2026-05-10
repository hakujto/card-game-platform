defmodule CardsProjectWeb.Content.DraftSessionControllerTest do
  use ExUnit.Case, async: true
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "status" => "test",
    "draft_type" => "test",
    "seats" => 0,
    "created_at" => ~N[2024-01-01 00:00:00],
    "status" => "WaitingForPlayers",
    "draft_type" => "Booster"
  }

  describe "GET /api/draft_sessions" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/draft_sessions")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/draft_sessions" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/draft_sessions", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/draft_sessions/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_draft_session(@valid_params)
      conn = get(conn, "/api/draft_sessions/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/draft_sessions/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_draft_session(@valid_params)
      conn = put(conn, "/api/draft_sessions/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/draft_sessions/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_draft_session(@valid_params)
      conn = delete(conn, "/api/draft_sessions/#{record.id}")
      assert response(conn, 204)
    end
  end
end
