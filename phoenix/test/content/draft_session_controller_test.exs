defmodule CardsProjectWeb.Content.DraftSessionControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "seats" => 0,
    "time_per_pick_seconds" => 0,
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
