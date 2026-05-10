defmodule CardsProjectWeb.Cards.DeckCardControllerTest do
  use ExUnit.Case, async: true
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "quantity" => 0,
    "is_commander" => true
  }

  describe "GET /api/deck_cards" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/deck_cards")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/deck_cards" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/deck_cards", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/deck_cards/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Cards.create_deck_card(@valid_params)
      conn = get(conn, "/api/deck_cards/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/deck_cards/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Cards.create_deck_card(@valid_params)
      conn = put(conn, "/api/deck_cards/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/deck_cards/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Cards.create_deck_card(@valid_params)
      conn = delete(conn, "/api/deck_cards/#{record.id}")
      assert response(conn, 204)
    end
  end
end
