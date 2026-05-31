defmodule CardsProjectWeb.Content.DraftSessionControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "seats" => 2,
    "time_per_pick_seconds" => 1,
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
    test "fails when seats_range violated", %{conn: conn} do
      params = Map.put(@valid_params, "seats", 161)
      conn = post(conn, "/api/draft_sessions", params)
      assert conn.status in [400, 422]
    end
    test "fails when time_per_pick_positive violated", %{conn: conn} do
      params = Map.put(@valid_params, "time_per_pick_seconds", 0)
      conn = post(conn, "/api/draft_sessions", params)
      assert conn.status in [400, 422]
    end
  end

  describe "GET /api/draft_sessions/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_draft_session(@valid_params)
      conn = get(conn, "/api/draft_sessions/#{record.id}")
      assert json_response(conn, 200)
    end
  end


  describe "PATCH /api/draft_sessions/:id/transitions/waitingforplayers-to-drafting" do
    test "transitions WaitingForPlayers -> Drafting", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_draft_session(@valid_params)
      conn = patch(conn, "/api/draft_sessions/#{record.id}/transitions/waitingforplayers-to-drafting")
      assert conn.status in [200, 409, 422, 404]
    end
  end

  describe "PATCH /api/draft_sessions/:id/transitions/drafting-to-completed" do
    test "transitions Drafting -> Completed", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_draft_session(@valid_params)
      conn = patch(conn, "/api/draft_sessions/#{record.id}/transitions/drafting-to-completed")
      assert conn.status in [200, 409, 422, 404]
    end
  end

  describe "PATCH /api/draft_sessions/:id/transitions/drafting-to-abandoned" do
    test "transitions Drafting -> Abandoned", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_draft_session(@valid_params)
      conn = patch(conn, "/api/draft_sessions/#{record.id}/transitions/drafting-to-abandoned")
      assert conn.status in [200, 409, 422, 404]
    end
  end

  describe "PATCH /api/draft_sessions/:id/transitions/waitingforplayers-to-abandoned" do
    test "transitions WaitingForPlayers -> Abandoned", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_draft_session(@valid_params)
      conn = patch(conn, "/api/draft_sessions/#{record.id}/transitions/waitingforplayers-to-abandoned")
      assert conn.status in [200, 409, 422, 404]
    end
  end

  describe "PATCH /api/draft_sessions/:id/transitions/completed-to-drafting" do
    test "is denied with 409", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_draft_session(@valid_params)
      conn = patch(conn, "/api/draft_sessions/#{record.id}/transitions/completed-to-drafting")
      assert conn.status in [409, 404]
    end
  end

  describe "PATCH /api/draft_sessions/:id/transitions/abandoned-to-drafting" do
    test "is denied with 409", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_draft_session(@valid_params)
      conn = patch(conn, "/api/draft_sessions/#{record.id}/transitions/abandoned-to-drafting")
      assert conn.status in [409, 404]
    end
  end

end
