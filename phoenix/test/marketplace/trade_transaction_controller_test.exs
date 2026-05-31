defmodule CardsProjectWeb.Marketplace.TradeTransactionControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "final_price" => 2,
    "platform_fee" => 0,
    "status" => "Pending"
  }

  describe "GET /api/trade_transactions" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/trade_transactions")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "GET /api/trade_transactions/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_trade_transaction(@valid_params)
      conn = get(conn, "/api/trade_transactions/#{record.id}")
      assert json_response(conn, 200)
    end
  end

end
