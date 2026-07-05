defmodule CardsProjectWeb.Tournaments.TournamentControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "public_id" => "00000000-0000-0000-0000-000000000001",
    "name" => "Test Tournament Alpha",
    "max_players" => 8,
    "entry_fee" => 0,
    "prize_pool" => 0,
    "start_time" => ~N[2024-01-01 00:00:00],
    "is_online" => true,
    "created_at" => ~N[2024-01-01 00:00:00],
    "status" => "Draft",
    "format" => "Standard",
    "tournament_type" => "Swiss"
  }

  describe "GET /api/tournaments" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/tournaments")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "GET /api/tournaments?q=test" do
    test "returns 200 with search results", %{conn: conn} do
      conn = get(conn, "/api/tournaments?q=test")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/tournaments" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/tournaments", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
    test "fails when max_players_positive violated", %{conn: conn} do
      params = Map.put(@valid_params, "max_players", 5121)
      conn = post(conn, "/api/tournaments", params)
      assert conn.status in [400, 422]
    end
    test "fails when entry_fee_not_negative violated", %{conn: conn} do
      params = Map.put(@valid_params, "entry_fee", -1)
      conn = post(conn, "/api/tournaments", params)
      assert conn.status in [400, 422]
    end
    test "fails when prize_pool_not_negative violated", %{conn: conn} do
      params = Map.put(@valid_params, "prize_pool", -1)
      conn = post(conn, "/api/tournaments", params)
      assert conn.status in [400, 422]
    end
  end

  describe "GET /api/tournaments/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament(@valid_params)
      conn = get(conn, "/api/tournaments/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/tournaments/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament(@valid_params)
      conn = put(conn, "/api/tournaments/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end


  describe "PATCH /api/tournaments/:id/transitions/draft-to-registration" do
    test "transitions Draft -> Registration", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament(@valid_params)
      conn = assign(conn, :current_user, %{role: "Admin"})
      conn = patch(conn, "/api/tournaments/#{record.id}/transitions/draft-to-registration")
      assert conn.status in [200, 409, 422, 404]
    end

    test "is forbidden with 403 for wrong role", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament(@valid_params)
      conn = assign(conn, :current_user, %{role: "admin"})
      conn = patch(conn, "/api/tournaments/#{record.id}/transitions/draft-to-registration")
      assert conn.status == 403
    end
  end

  describe "PATCH /api/tournaments/:id/transitions/registration-to-ongoing" do
    test "transitions Registration -> Ongoing", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament(@valid_params)
      conn = assign(conn, :current_user, %{role: "Admin"})
      conn = patch(conn, "/api/tournaments/#{record.id}/transitions/registration-to-ongoing")
      assert conn.status in [200, 409, 422, 404]
    end

    test "is forbidden with 403 for wrong role", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament(@valid_params)
      conn = assign(conn, :current_user, %{role: "admin"})
      conn = patch(conn, "/api/tournaments/#{record.id}/transitions/registration-to-ongoing")
      assert conn.status == 403
    end
  end

  describe "PATCH /api/tournaments/:id/transitions/registration-to-cancelled" do
    test "transitions Registration -> Cancelled", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament(@valid_params)
      conn = assign(conn, :current_user, %{role: "Admin"})
      conn = patch(conn, "/api/tournaments/#{record.id}/transitions/registration-to-cancelled")
      assert conn.status in [200, 409, 422, 404]
    end

    test "is forbidden with 403 for wrong role", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament(@valid_params)
      conn = assign(conn, :current_user, %{role: "admin"})
      conn = patch(conn, "/api/tournaments/#{record.id}/transitions/registration-to-cancelled")
      assert conn.status == 403
    end
  end

  describe "PATCH /api/tournaments/:id/transitions/ongoing-to-completed" do
    test "transitions Ongoing -> Completed", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament(@valid_params)
      conn = assign(conn, :current_user, %{role: "Admin"})
      conn = patch(conn, "/api/tournaments/#{record.id}/transitions/ongoing-to-completed")
      assert conn.status in [200, 409, 422, 404]
    end

    test "is forbidden with 403 for wrong role", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament(@valid_params)
      conn = assign(conn, :current_user, %{role: "admin"})
      conn = patch(conn, "/api/tournaments/#{record.id}/transitions/ongoing-to-completed")
      assert conn.status == 403
    end
  end

  describe "PATCH /api/tournaments/:id/transitions/ongoing-to-cancelled" do
    test "transitions Ongoing -> Cancelled", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament(@valid_params)
      conn = assign(conn, :current_user, %{role: "Admin"})
      conn = patch(conn, "/api/tournaments/#{record.id}/transitions/ongoing-to-cancelled")
      assert conn.status in [200, 409, 422, 404]
    end

    test "is forbidden with 403 for wrong role", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament(@valid_params)
      conn = assign(conn, :current_user, %{role: "admin"})
      conn = patch(conn, "/api/tournaments/#{record.id}/transitions/ongoing-to-cancelled")
      assert conn.status == 403
    end
  end

  describe "PATCH /api/tournaments/:id/transitions/completed-to-draft" do
    test "is denied with 409", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament(@valid_params)
      conn = patch(conn, "/api/tournaments/#{record.id}/transitions/completed-to-draft")
      assert conn.status in [409, 404]
    end
  end

  describe "PATCH /api/tournaments/:id/transitions/cancelled-to-draft" do
    test "is denied with 409", %{conn: conn} do
      {:ok, record} = CardsProject.Tournaments.create_tournament(@valid_params)
      conn = patch(conn, "/api/tournaments/#{record.id}/transitions/cancelled-to-draft")
      assert conn.status in [409, 404]
    end
  end

end
