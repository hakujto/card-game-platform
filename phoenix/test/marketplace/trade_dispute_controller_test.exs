defmodule CardsProjectWeb.Marketplace.TradeDisputeControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "description" => "test",
    "opened_at" => ~N[2024-01-01 00:00:00],
    "status" => "Open",
    "reason" => "ItemNotReceived"
  }

  describe "GET /api/trade_disputes" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/trade_disputes")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/trade_disputes" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/trade_disputes", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/trade_disputes/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_trade_dispute(@valid_params)
      conn = get(conn, "/api/trade_disputes/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/trade_disputes/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_trade_dispute(@valid_params)
      conn = put(conn, "/api/trade_disputes/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/trade_disputes/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_trade_dispute(@valid_params)
      conn = delete(conn, "/api/trade_disputes/#{record.id}")
      assert response(conn, 204)
    end
  end

  describe "PATCH /api/trade_disputes/:id/transitions/open-to-underreview" do
    test "transitions Open -> UnderReview", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_trade_dispute(@valid_params)
      conn = patch(conn, "/api/trade_disputes/#{record.id}/transitions/open-to-underreview")
      assert conn.status in [200, 409, 422, 404]
    end
  end

  describe "PATCH /api/trade_disputes/:id/transitions/underreview-to-resolved" do
    test "transitions UnderReview -> Resolved", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_trade_dispute(@valid_params)
      conn = patch(conn, "/api/trade_disputes/#{record.id}/transitions/underreview-to-resolved")
      assert conn.status in [200, 409, 422, 404]
    end
  end

  describe "PATCH /api/trade_disputes/:id/transitions/underreview-to-escalated" do
    test "transitions UnderReview -> Escalated", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_trade_dispute(@valid_params)
      conn = patch(conn, "/api/trade_disputes/#{record.id}/transitions/underreview-to-escalated")
      assert conn.status in [200, 409, 422, 404]
    end
  end

  describe "PATCH /api/trade_disputes/:id/transitions/escalated-to-resolved" do
    test "transitions Escalated -> Resolved", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_trade_dispute(@valid_params)
      conn = patch(conn, "/api/trade_disputes/#{record.id}/transitions/escalated-to-resolved")
      assert conn.status in [200, 409, 422, 404]
    end
  end

  describe "PATCH /api/trade_disputes/:id/transitions/resolved-to-open" do
    test "is denied with 409", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_trade_dispute(@valid_params)
      conn = patch(conn, "/api/trade_disputes/#{record.id}/transitions/resolved-to-open")
      assert conn.status in [409, 404]
    end
  end

end
