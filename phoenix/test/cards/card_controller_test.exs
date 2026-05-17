defmodule CardsProjectWeb.Cards.CardControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "name" => "test",
    "mana_cost" => 0,
    "description" => "test",
    "is_banned" => true,
    "is_restricted" => true,
    "power_level" => 0,
    "card_type" => "Creature",
    "rarity" => "Common",
    "mana_colors" => "White",
    "legal_formats" => "Standard"
  }

  describe "GET /api/cards" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/cards")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/cards" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/cards", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/cards/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Cards.create_card(@valid_params)
      conn = get(conn, "/api/cards/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/cards/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Cards.create_card(@valid_params)
      conn = put(conn, "/api/cards/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/cards/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Cards.create_card(@valid_params)
      conn = delete(conn, "/api/cards/#{record.id}")
      assert response(conn, 204)
    end
  end
end
