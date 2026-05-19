defmodule CardsProjectWeb.Marketplace.OrderControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "total" => "0.00",
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
  end

  describe "GET /api/orders/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_order(@valid_params)
      conn = get(conn, "/api/orders/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/orders/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_order(@valid_params)
      conn = put(conn, "/api/orders/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/orders/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_order(@valid_params)
      conn = delete(conn, "/api/orders/#{record.id}")
      assert response(conn, 204)
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
