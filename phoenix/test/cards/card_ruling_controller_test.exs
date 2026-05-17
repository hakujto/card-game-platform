defmodule CardsProjectWeb.Cards.CardRulingControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "ruling_text" => "test",
    "published_at" => ~D[2024-01-01],
    "source" => "test"
  }

  describe "GET /api/card_rulings" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/card_rulings")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/card_rulings" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/card_rulings", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/card_rulings/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Cards.create_card_ruling(@valid_params)
      conn = get(conn, "/api/card_rulings/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/card_rulings/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Cards.create_card_ruling(@valid_params)
      conn = put(conn, "/api/card_rulings/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/card_rulings/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Cards.create_card_ruling(@valid_params)
      conn = delete(conn, "/api/card_rulings/#{record.id}")
      assert response(conn, 204)
    end
  end
end
