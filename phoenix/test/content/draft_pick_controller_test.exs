defmodule CardsProjectWeb.Content.DraftPickControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "pick_number" => 1,
    "pack_number" => 1,
    "picked_at" => ~N[2024-01-01 00:00:00]
  }

  describe "GET /api/draft_picks" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/draft_picks")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "GET /api/draft_picks/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_draft_pick(@valid_params)
      conn = get(conn, "/api/draft_picks/#{record.id}")
      assert json_response(conn, 200)
    end
  end

end
