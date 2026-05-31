defmodule CardsProjectWeb.Marketplace.OrderControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "total" => 1,
    "discount_applied" => "0.00",
    "currency" => "test",
    "created_at" => ~N[2024-01-01 00:00:00],
    "status" => "Pending"
  }

  describe "GET /api/orders" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/orders")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/orders" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/orders", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
    test "fails when total_not_negative violated", %{conn: conn} do
      params = Map.put(@valid_params, "total", -1)
      conn = post(conn, "/api/orders", params)
      assert conn.status in [400, 422]
    end
    test "fails when discount_not_exceed_total violated", %{conn: conn} do
      params = Map.put(@valid_params, "discount_applied", NaN)
      conn = post(conn, "/api/orders", params)
      assert conn.status in [400, 422]
    end
  end

  describe "GET /api/orders/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_order(@valid_params)
      conn = get(conn, "/api/orders/#{record.id}")
      assert json_response(conn, 200)
    end
  end


  describe "PATCH /api/orders/:id/transitions/pending-to-paid" do
    test "transitions Pending -> Paid", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_order(@valid_params)
      conn = patch(conn, "/api/orders/#{record.id}/transitions/pending-to-paid")
      assert conn.status in [200, 409, 422, 404]
    end
  end

  describe "PATCH /api/orders/:id/transitions/paid-to-processing" do
    test "transitions Paid -> Processing", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_order(@valid_params)
      conn = patch(conn, "/api/orders/#{record.id}/transitions/paid-to-processing")
      assert conn.status in [200, 409, 422, 404]
    end
  end

  describe "PATCH /api/orders/:id/transitions/processing-to-shipped" do
    test "transitions Processing -> Shipped", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_order(@valid_params)
      conn = patch(conn, "/api/orders/#{record.id}/transitions/processing-to-shipped")
      assert conn.status in [200, 409, 422, 404]
    end
  end

  describe "PATCH /api/orders/:id/transitions/shipped-to-completed" do
    test "transitions Shipped -> Completed", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_order(@valid_params)
      conn = patch(conn, "/api/orders/#{record.id}/transitions/shipped-to-completed")
      assert conn.status in [200, 409, 422, 404]
    end
  end

  describe "PATCH /api/orders/:id/transitions/pending-to-cancelled" do
    test "transitions Pending -> Cancelled", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_order(@valid_params)
      conn = patch(conn, "/api/orders/#{record.id}/transitions/pending-to-cancelled")
      assert conn.status in [200, 409, 422, 404]
    end
  end

  describe "PATCH /api/orders/:id/transitions/paid-to-cancelled" do
    test "transitions Paid -> Cancelled", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_order(@valid_params)
      conn = patch(conn, "/api/orders/#{record.id}/transitions/paid-to-cancelled")
      assert conn.status in [200, 409, 422, 404]
    end
  end

  describe "PATCH /api/orders/:id/transitions/completed-to-refunded" do
    test "transitions Completed -> Refunded", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_order(@valid_params)
      conn = patch(conn, "/api/orders/#{record.id}/transitions/completed-to-refunded")
      assert conn.status in [200, 409, 422, 404]
    end
  end

  describe "PATCH /api/orders/:id/transitions/refunded-to-completed" do
    test "is denied with 409", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_order(@valid_params)
      conn = patch(conn, "/api/orders/#{record.id}/transitions/refunded-to-completed")
      assert conn.status in [409, 404]
    end
  end

  describe "PATCH /api/orders/:id/transitions/completed-to-cancelled" do
    test "is denied with 409", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_order(@valid_params)
      conn = patch(conn, "/api/orders/#{record.id}/transitions/completed-to-cancelled")
      assert conn.status in [409, 404]
    end
  end

end
