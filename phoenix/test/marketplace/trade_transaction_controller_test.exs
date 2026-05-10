defmodule CardsProjectWeb.Marketplace.TradeTransactionControllerTest do
  use ExUnit.Case, async: true
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "final_price" => "0.00",
    "platform_fee" => "0.00",
    "status" => "test",
    "status" => "Pending"
  }

  describe "GET /api/trade_transactions" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/trade_transactions")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/trade_transactions" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/trade_transactions", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/trade_transactions/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_trade_transaction(@valid_params)
      conn = get(conn, "/api/trade_transactions/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/trade_transactions/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_trade_transaction(@valid_params)
      conn = put(conn, "/api/trade_transactions/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/trade_transactions/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_trade_transaction(@valid_params)
      conn = delete(conn, "/api/trade_transactions/#{record.id}")
      assert response(conn, 204)
    end
  end
end
