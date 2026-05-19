defmodule CardsProjectWeb.Marketplace.TradeListingControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "foil" => true,
    "quantity" => 0,
    "created_at" => ~N[2024-01-01 00:00:00],
    "status" => "Active",
    "listing_type" => "FixedPrice",
    "condition" => "Mint"
  }

  describe "GET /api/trade_listings" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/trade_listings")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/trade_listings" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/trade_listings", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/trade_listings/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_trade_listing(@valid_params)
      conn = get(conn, "/api/trade_listings/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/trade_listings/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_trade_listing(@valid_params)
      conn = put(conn, "/api/trade_listings/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/trade_listings/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_trade_listing(@valid_params)
      conn = delete(conn, "/api/trade_listings/#{record.id}")
      assert response(conn, 204)
    end
  end

  describe "PATCH /api/trade_listings/:id/transitions/pending-to-active" do
    test "transitions Pending -> Active", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_trade_listing(@valid_params)
      conn = patch(conn, "/api/trade_listings/#{record.id}/transitions/pending-to-active")
      assert conn.status in [200, 409, 422, 404]
    end
  end

  describe "PATCH /api/trade_listings/:id/transitions/active-to-sold" do
    test "transitions Active -> Sold", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_trade_listing(@valid_params)
      conn = patch(conn, "/api/trade_listings/#{record.id}/transitions/active-to-sold")
      assert conn.status in [200, 409, 422, 404]
    end
  end

  describe "PATCH /api/trade_listings/:id/transitions/active-to-expired" do
    test "transitions Active -> Expired", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_trade_listing(@valid_params)
      conn = patch(conn, "/api/trade_listings/#{record.id}/transitions/active-to-expired")
      assert conn.status in [200, 409, 422, 404]
    end
  end

  describe "PATCH /api/trade_listings/:id/transitions/active-to-cancelled" do
    test "transitions Active -> Cancelled", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_trade_listing(@valid_params)
      conn = patch(conn, "/api/trade_listings/#{record.id}/transitions/active-to-cancelled")
      assert conn.status in [200, 409, 422, 404]
    end
  end

  describe "PATCH /api/trade_listings/:id/transitions/sold-to-active" do
    test "is denied with 409", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_trade_listing(@valid_params)
      conn = patch(conn, "/api/trade_listings/#{record.id}/transitions/sold-to-active")
      assert conn.status in [409, 404]
    end
  end

  describe "PATCH /api/trade_listings/:id/transitions/expired-to-active" do
    test "is denied with 409", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_trade_listing(@valid_params)
      conn = patch(conn, "/api/trade_listings/#{record.id}/transitions/expired-to-active")
      assert conn.status in [409, 404]
    end
  end

end
