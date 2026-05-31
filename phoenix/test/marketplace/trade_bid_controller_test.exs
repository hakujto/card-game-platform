defmodule CardsProjectWeb.Marketplace.TradeBidControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "amount" => 1,
    "placed_at" => ~N[2024-01-01 00:00:00],
    "is_winning" => true
  }

  describe "GET /api/trade_bids" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/trade_bids")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/trade_bids" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/trade_bids", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
    test "fails when amount_positive violated", %{conn: conn} do
      params = Map.put(@valid_params, "amount", 0)
      conn = post(conn, "/api/trade_bids", params)
      assert conn.status in [400, 422]
    end
  end

  describe "GET /api/trade_bids/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_trade_bid(@valid_params)
      conn = get(conn, "/api/trade_bids/#{record.id}")
      assert json_response(conn, 200)
    end
  end

end
