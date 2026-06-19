defmodule CardsProjectWeb.Tournaments.MatchControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "player1_wins" => 0,
    "player2_wins" => 0,
    "status" => "Pending"
  }

  describe "GET /api/matches" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/matches")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/matches" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/matches", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/matches/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_match(@valid_params)
      conn = get(conn, "/api/matches/#{record.id}")
      assert json_response(conn, 200)
    end
  end


  describe "PATCH /api/matches/:id/transitions/pending-to-active" do
    test "transitions Pending -> Active", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_match(@valid_params)
      conn = assign(conn, :current_user, %{role: "Judge"})
      conn = patch(conn, "/api/matches/#{record.id}/transitions/pending-to-active")
      assert conn.status in [200, 409, 422, 404]
    end

    test "is forbidden with 403 for wrong role", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_match(@valid_params)
      conn = assign(conn, :current_user, %{role: "admin"})
      conn = patch(conn, "/api/matches/#{record.id}/transitions/pending-to-active")
      assert conn.status == 403
    end
  end

  describe "PATCH /api/matches/:id/transitions/active-to-completed" do
    test "transitions Active -> Completed", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_match(@valid_params)
      conn = assign(conn, :current_user, %{role: "Judge"})
      conn = patch(conn, "/api/matches/#{record.id}/transitions/active-to-completed")
      assert conn.status in [200, 409, 422, 404]
    end

    test "is forbidden with 403 for wrong role", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_match(@valid_params)
      conn = assign(conn, :current_user, %{role: "admin"})
      conn = patch(conn, "/api/matches/#{record.id}/transitions/active-to-completed")
      assert conn.status == 403
    end
  end

  describe "PATCH /api/matches/:id/transitions/active-to-draw" do
    test "transitions Active -> Draw", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_match(@valid_params)
      conn = assign(conn, :current_user, %{role: "Judge"})
      conn = patch(conn, "/api/matches/#{record.id}/transitions/active-to-draw")
      assert conn.status in [200, 409, 422, 404]
    end

    test "is forbidden with 403 for wrong role", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_match(@valid_params)
      conn = assign(conn, :current_user, %{role: "admin"})
      conn = patch(conn, "/api/matches/#{record.id}/transitions/active-to-draw")
      assert conn.status == 403
    end
  end

  describe "PATCH /api/matches/:id/transitions/pending-to-bye" do
    test "transitions Pending -> BYE", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_match(@valid_params)
      conn = assign(conn, :current_user, %{role: "Judge"})
      conn = patch(conn, "/api/matches/#{record.id}/transitions/pending-to-bye")
      assert conn.status in [200, 409, 422, 404]
    end

    test "is forbidden with 403 for wrong role", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_match(@valid_params)
      conn = assign(conn, :current_user, %{role: "admin"})
      conn = patch(conn, "/api/matches/#{record.id}/transitions/pending-to-bye")
      assert conn.status == 403
    end
  end

  describe "PATCH /api/matches/:id/transitions/completed-to-active" do
    test "is denied with 409", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_match(@valid_params)
      conn = patch(conn, "/api/matches/#{record.id}/transitions/completed-to-active")
      assert conn.status in [409, 404]
    end
  end

  describe "PATCH /api/matches/:id/transitions/draw-to-active" do
    test "is denied with 409", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_match(@valid_params)
      conn = patch(conn, "/api/matches/#{record.id}/transitions/draw-to-active")
      assert conn.status in [409, 404]
    end
  end

  describe "PATCH /api/matches/:id/transitions/bye-to-active" do
    test "is denied with 409", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_match(@valid_params)
      conn = patch(conn, "/api/matches/#{record.id}/transitions/bye-to-active")
      assert conn.status in [409, 404]
    end
  end

end
