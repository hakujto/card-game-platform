defmodule CardsProjectWeb.Marketplace.CardPriceHistoryControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "price_date" => ~D[2024-01-01],
    "avg_price" => "0.00",
    "min_price" => 0,
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

  describe "GET /api/card_price_histories/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Marketplace.create_card_price_history(@valid_params)
      conn = get(conn, "/api/card_price_histories/#{record.id}")
      assert json_response(conn, 200)
    end
  end

end
