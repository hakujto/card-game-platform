defmodule CardsProjectWeb.Content.DraftParticipantControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "seat_number" => 1,
    "joined_at" => ~N[2024-01-01 00:00:00]
  }

  describe "GET /api/draft_participants" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/draft_participants")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/draft_participants" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/draft_participants", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
    test "fails when seat_number_positive violated", %{conn: conn} do
      params = Map.put(@valid_params, "seat_number", 0)
      conn = post(conn, "/api/draft_participants", params)
      assert conn.status in [400, 422]
    end
  end

  describe "GET /api/draft_participants/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_draft_participant(@valid_params)
      conn = get(conn, "/api/draft_participants/#{record.id}")
      assert json_response(conn, 200)
    end
  end

end
