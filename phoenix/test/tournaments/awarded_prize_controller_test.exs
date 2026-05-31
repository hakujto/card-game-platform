defmodule CardsProjectWeb.Tournaments.AwardedPrizeControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "final_placement" => 1,
    "awarded_at" => ~N[2024-01-01 00:00:00],
    "claimed" => true
  }

  describe "GET /api/awarded_prizes" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/awarded_prizes")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "GET /api/awarded_prizes/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_awarded_prize(@valid_params)
      conn = get(conn, "/api/awarded_prizes/#{record.id}")
      assert json_response(conn, 200)
    end
  end

end
