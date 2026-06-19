defmodule CardsProjectWeb.Players.FriendshipControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "created_at" => ~N[2024-01-01 00:00:00],
    "status" => "Pending"
  }

  setup %{conn: conn} do
    {:ok, owner} = CardsProject.Players.create_player(%{"display_name" => "test", "rank" => "Bronze", "rating" => 0, "peak_rating" => 0, "is_verified" => true, "created_at" => ~N[2024-01-01 00:00:00]})
    valid_params = Map.put(@valid_params, "requester_id", owner.id)
    conn = assign(conn, :current_user, %{id: owner.id})
    {:ok, conn: conn, owner: owner, valid_params: valid_params}
  end

  describe "GET /api/friendships" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/friendships")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/friendships" do
    test "creates record and returns 201", %{conn: conn, valid_params: valid_params} do
      conn = post(conn, "/api/friendships", valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/friendships/:id" do
    test "returns 200 for existing record", %{conn: conn, valid_params: valid_params} do
      {:ok, record} = CardsProject.Players.create_friendship(valid_params)
      conn = get(conn, "/api/friendships/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/friendships/:id" do
    test "deletes and returns 204", %{conn: conn, valid_params: valid_params} do
      {:ok, record} = CardsProject.Players.create_friendship(valid_params)
      conn = delete(conn, "/api/friendships/#{record.id}")
      assert response(conn, 204)
    end
  end

end
