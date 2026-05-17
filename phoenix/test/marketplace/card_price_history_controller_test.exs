defmodule CardsProjectWeb.Marketplace.CardPriceHistoryControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "price_date" => ~D[2024-01-01],
    "avg_price" => "0.00",
    "min_price" => "0.00",
    "max_price" => "0.00",
    "volume" => 0,
    "foil" => true
  }

  describe "GET /api/card_price_histories" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/card_price_histories")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/card_price_histories" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/card_price_histories", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/card_price_histories/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_card_price_history(@valid_params)
      conn = get(conn, "/api/card_price_histories/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/card_price_histories/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_card_price_history(@valid_params)
      conn = put(conn, "/api/card_price_histories/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/card_price_histories/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_card_price_history(@valid_params)
      conn = delete(conn, "/api/card_price_histories/#{record.id}")
      assert response(conn, 204)
    end
  end
end
