defmodule CardsProjectWeb.Marketplace.OrderControllerTest do
  use ExUnit.Case, async: true
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "status" => "test",
    "total" => "0.00",
    "discount_applied" => "0.00",
    "currency" => "test",
    "created_at" => ~N[2024-01-01 00:00:00],
    "status" => "Pending",
    "payment_method" => "Card"
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
end
