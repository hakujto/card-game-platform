defmodule CardsProjectWeb.Marketplace.ProductControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "name" => "test",
    "price" => 1,
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

  describe "GET /api/products?q=test" do
    test "returns 200 with search results", %{conn: conn} do
      conn = get(conn, "/api/products?q=test")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/products" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/products", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
    test "fails when price_positive violated", %{conn: conn} do
      params = Map.put(@valid_params, "price", 0)
      conn = post(conn, "/api/products", params)
      assert conn.status in [400, 422]
    end
    test "fails when stock_not_negative violated", %{conn: conn} do
      params = Map.put(@valid_params, "stock", -1)
      conn = post(conn, "/api/products", params)
      assert conn.status in [400, 422]
    end
    test "fails when discount_percent_range violated", %{conn: conn} do
      params = Map.put(@valid_params, "discount_percent", 1001)
      conn = post(conn, "/api/products", params)
      assert conn.status in [400, 422]
    end
  end

  describe "GET /api/products/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_product(@valid_params)
      conn = get(conn, "/api/products/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  @patch_params %{
    "featured" => true
  }

  describe "PUT /api/products/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_product(@valid_params)
      conn = put(conn, "/api/products/#{record.id}", @patch_params)
      assert json_response(conn, 200)
    end
  end

end
