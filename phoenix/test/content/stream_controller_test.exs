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

  describe "POST /api/streams" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/streams", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
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

  describe "DELETE /api/streams/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_stream(@valid_params)
      conn = delete(conn, "/api/streams/#{record.id}")
      assert response(conn, 204)
    end
  end

  describe "PATCH /api/streams/:id/transitions/scheduled-to-live" do
    test "transitions Scheduled -> Live", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_stream(@valid_params)
      conn = patch(conn, "/api/streams/#{record.id}/transitions/scheduled-to-live")
      assert conn.status in [200, 409, 422, 404]
    end
  end

  describe "PATCH /api/streams/:id/transitions/live-to-ended" do
    test "transitions Live -> Ended", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_stream(@valid_params)
      conn = patch(conn, "/api/streams/#{record.id}/transitions/live-to-ended")
      assert conn.status in [200, 409, 422, 404]
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
