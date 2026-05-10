defmodule CardsProjectWeb.Marketplace.CouponControllerTest do
  use ExUnit.Case, async: true
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "code" => "test",
    "discount_type" => "test",
    "discount_value" => "0.00",
    "min_order_value" => "0.00",
    "uses_count" => 0,
    "valid_from" => ~N[2024-01-01 00:00:00],
    "valid_until" => ~N[2024-01-01 00:00:00],
    "is_active" => true,
    "discount_type" => "Percent"
  }

  describe "GET /api/coupons" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/coupons")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/coupons" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/coupons", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/coupons/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_coupon(@valid_params)
      conn = get(conn, "/api/coupons/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/coupons/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_coupon(@valid_params)
      conn = put(conn, "/api/coupons/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/coupons/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_coupon(@valid_params)
      conn = delete(conn, "/api/coupons/#{record.id}")
      assert response(conn, 204)
    end
  end
end
