defmodule CardsProjectWeb.Cards.CardControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "public_id" => "00000000-0000-0000-0000-000000000001",
    "name" => "Test Lightning Bolt",
    "mana_cost" => 1,
    "description" => "test",
    "is_banned" => true,
    "is_restricted" => true,
    "power_level" => 3,
    "total_copies_in_circulation" => 0,
    "card_type" => "Spell",
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

  describe "GET /api/cards?q=test" do
    test "returns 200 with search results", %{conn: conn} do
      conn = get(conn, "/api/cards?q=test")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/cards" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/cards", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
    test "fails when mana_cost_range violated", %{conn: conn} do
      params = Map.put(@valid_params, "mana_cost", 201)
      conn = post(conn, "/api/cards", params)
      assert conn.status in [400, 422]
    end
    test "fails when power_level_range violated", %{conn: conn} do
      params = Map.put(@valid_params, "power_level", 101)
      conn = post(conn, "/api/cards", params)
      assert conn.status in [400, 422]
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

end
