defmodule CardsProjectWeb.Marketplace.ProductControllerTest do
  use ExUnit.Case, async: true
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "name" => "test",
    "product_type" => "test",
    "price" => "0.00",
    "stock" => 0,
    "active" => true,
    "discount_percent" => 0,
    "featured" => true,
    "product_type" => "SingleCard"
  }

  describe "GET /api/products" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/products")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/products" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/products", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/products/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_product(@valid_params)
      conn = get(conn, "/api/products/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/products/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_product(@valid_params)
      conn = put(conn, "/api/products/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/products/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_product(@valid_params)
      conn = delete(conn, "/api/products/#{record.id}")
      assert response(conn, 204)
    end
  end
end
