defmodule CardsProjectWeb.Marketplace.OrderItemControllerTest do
  use ExUnit.Case, async: true
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "quantity" => 0,
    "price_at_purchase" => "0.00",
    "foil" => true
  }

  describe "GET /api/order_items" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/order_items")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/order_items" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/order_items", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/order_items/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_order_item(@valid_params)
      conn = get(conn, "/api/order_items/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/order_items/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_order_item(@valid_params)
      conn = put(conn, "/api/order_items/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/order_items/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_order_item(@valid_params)
      conn = delete(conn, "/api/order_items/#{record.id}")
      assert response(conn, 204)
    end
  end
end
