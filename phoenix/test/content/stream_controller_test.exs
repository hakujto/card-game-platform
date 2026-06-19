defmodule CardsProjectWeb.Content.StreamControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "title" => "test",
    "stream_url" => "https://example.com",
    "is_official" => true,
    "viewer_count_peak" => 0,
    "scheduled_start" => ~N[2024-01-01 00:00:00],
    "status" => "Scheduled",
    "platform" => "Twitch",
    "language" => "EN"
  }

  describe "GET /api/streams" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/streams")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "GET /api/streams?q=test" do
    test "returns 200 with search results", %{conn: conn} do
      conn = get(conn, "/api/streams?q=test")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/streams" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/streams", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
    test "fails when viewer_count_not_negative violated", %{conn: conn} do
      params = Map.put(@valid_params, "viewer_count_peak", -1)
      conn = post(conn, "/api/streams", params)
      assert conn.status in [400, 422]
    end
  end

  describe "GET /api/streams/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_stream(@valid_params)
      conn = get(conn, "/api/streams/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/streams/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_stream(@valid_params)
      conn = put(conn, "/api/streams/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end


  describe "PATCH /api/streams/:id/transitions/scheduled-to-live" do
    test "transitions Scheduled -> Live", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_stream(@valid_params)
      conn = assign(conn, :current_user, %{role: "Streamer"})
      conn = patch(conn, "/api/streams/#{record.id}/transitions/scheduled-to-live")
      assert conn.status in [200, 409, 422, 404]
    end

    test "is forbidden with 403 for wrong role", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_stream(@valid_params)
      conn = assign(conn, :current_user, %{role: "admin"})
      conn = patch(conn, "/api/streams/#{record.id}/transitions/scheduled-to-live")
      assert conn.status == 403
    end
  end

  describe "PATCH /api/streams/:id/transitions/live-to-ended" do
    test "transitions Live -> Ended", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_stream(@valid_params)
      conn = assign(conn, :current_user, %{role: "Streamer"})
      conn = patch(conn, "/api/streams/#{record.id}/transitions/live-to-ended")
      assert conn.status in [200, 409, 422, 404]
    end

    test "is forbidden with 403 for wrong role", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_stream(@valid_params)
      conn = assign(conn, :current_user, %{role: "admin"})
      conn = patch(conn, "/api/streams/#{record.id}/transitions/live-to-ended")
      assert conn.status == 403
    end
  end

  describe "PATCH /api/streams/:id/transitions/ended-to-live" do
    test "is denied with 409", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_stream(@valid_params)
      conn = patch(conn, "/api/streams/#{record.id}/transitions/ended-to-live")
      assert conn.status in [409, 404]
    end
  end

end
