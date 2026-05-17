defmodule CardsProjectWeb.Cards.CardAbilityControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "ability_text" => "test",
    "ability_type" => "Keyword"
  }

  describe "GET /api/card_abilities" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/card_abilities")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/card_abilities" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/card_abilities", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/card_abilities/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Cards.create_card_ability(@valid_params)
      conn = get(conn, "/api/card_abilities/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/card_abilities/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Cards.create_card_ability(@valid_params)
      conn = put(conn, "/api/card_abilities/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/card_abilities/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Cards.create_card_ability(@valid_params)
      conn = delete(conn, "/api/card_abilities/#{record.id}")
      assert response(conn, 204)
    end
  end
end
