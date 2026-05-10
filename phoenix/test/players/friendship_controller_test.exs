defmodule CardsProjectWeb.Players.FriendshipControllerTest do
  use ExUnit.Case, async: true
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "status" => "test",
    "created_at" => ~N[2024-01-01 00:00:00],
    "status" => "Pending"
  }

  describe "GET /api/friendships" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/friendships")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/friendships" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/friendships", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/friendships/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_friendship(@valid_params)
      conn = get(conn, "/api/friendships/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/friendships/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_friendship(@valid_params)
      conn = put(conn, "/api/friendships/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/friendships/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Players.create_friendship(@valid_params)
      conn = delete(conn, "/api/friendships/#{record.id}")
      assert response(conn, 204)
    end
  end
end
