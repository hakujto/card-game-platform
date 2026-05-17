defmodule CardsProjectWeb.Cards.DeckControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "name" => "test",
    "is_public" => true,
    "is_tournament_legal" => true,
    "wins" => 0,
    "losses" => 0,
    "created_at" => ~N[2024-01-01 00:00:00],
    "updated_at" => ~N[2024-01-01 00:00:00],
    "format" => "Standard"
  }

  describe "GET /api/decks" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/decks")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/decks" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/decks", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/decks/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Cards.create_deck(@valid_params)
      conn = get(conn, "/api/decks/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/decks/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Cards.create_deck(@valid_params)
      conn = put(conn, "/api/decks/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/decks/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Cards.create_deck(@valid_params)
      conn = delete(conn, "/api/decks/#{record.id}")
      assert response(conn, 204)
    end
  end
end
