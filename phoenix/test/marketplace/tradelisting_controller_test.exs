defmodule CardsProjectWeb.Marketplace.TradelistingControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "foil" => true,
    "quantity" => 0,
    "created_at" => ~N[2024-01-01 00:00:00],
    "listing_type" => "FixedPrice",
    "condition" => "Mint",
    "status" => "Active"
  }

  describe "GET /api/tradelistings" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/tradelistings")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/tradelistings" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/tradelistings", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/tradelistings/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_tradelisting(@valid_params)
      conn = get(conn, "/api/tradelistings/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/tradelistings/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_tradelisting(@valid_params)
      conn = put(conn, "/api/tradelistings/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/tradelistings/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_tradelisting(@valid_params)
      conn = delete(conn, "/api/tradelistings/#{record.id}")
      assert response(conn, 204)
    end
  end
end
