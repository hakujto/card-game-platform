defmodule CardsProjectWeb.Cards.CardSetControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "name" => "test",
    "code" => "test",
    "release_date" => ~D[2024-01-01],
    "total_cards" => 0,
    "is_rotated" => true,
    "set_type" => "Core"
  }

  describe "GET /api/card_sets" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/card_sets")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/card_sets" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/card_sets", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/card_sets/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Cards.create_card_set(@valid_params)
      conn = get(conn, "/api/card_sets/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/card_sets/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Cards.create_card_set(@valid_params)
      conn = put(conn, "/api/card_sets/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/card_sets/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Cards.create_card_set(@valid_params)
      conn = delete(conn, "/api/card_sets/#{record.id}")
      assert response(conn, 204)
    end
  end
end
