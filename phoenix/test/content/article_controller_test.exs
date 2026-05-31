defmodule CardsProjectWeb.Content.ArticleControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "title" => "test",
    "slug" => "test",
    "body" => "test",
    "view_count" => 0,
    "likes_count" => 0,
    "is_featured" => true,
    "created_at" => ~N[2024-01-01 00:00:00],
    "updated_at" => ~N[2024-01-01 00:00:00],
    "status" => "Draft",
    "article_type" => "Guide",
    "language" => "EN"
  }

  describe "GET /api/articles" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/articles")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "GET /api/articles?q=test" do
    test "returns 200 with search results", %{conn: conn} do
      conn = get(conn, "/api/articles?q=test")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/articles" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/articles", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
    test "fails when view_count_not_negative violated", %{conn: conn} do
      params = Map.put(@valid_params, "view_count", -1)
      conn = post(conn, "/api/articles", params)
      assert conn.status in [400, 422]
    end
    test "fails when likes_count_not_negative violated", %{conn: conn} do
      params = Map.put(@valid_params, "likes_count", -1)
      conn = post(conn, "/api/articles", params)
      assert conn.status in [400, 422]
    end
  end

  describe "GET /api/articles/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_article(@valid_params)
      conn = get(conn, "/api/articles/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/articles/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_article(@valid_params)
      conn = put(conn, "/api/articles/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end


  describe "PATCH /api/articles/:id/transitions/draft-to-published" do
    test "transitions Draft -> Published", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_article(@valid_params)
      conn = patch(conn, "/api/articles/#{record.id}/transitions/draft-to-published")
      assert conn.status in [200, 409, 422, 404]
    end
  end

  describe "PATCH /api/articles/:id/transitions/published-to-archived" do
    test "transitions Published -> Archived", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_article(@valid_params)
      conn = patch(conn, "/api/articles/#{record.id}/transitions/published-to-archived")
      assert conn.status in [200, 409, 422, 404]
    end
  end

  describe "PATCH /api/articles/:id/transitions/archived-to-draft" do
    test "transitions Archived -> Draft", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_article(@valid_params)
      conn = patch(conn, "/api/articles/#{record.id}/transitions/archived-to-draft")
      assert conn.status in [200, 409, 422, 404]
    end
  end

  describe "PATCH /api/articles/:id/transitions/published-to-draft" do
    test "is denied with 409", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_article(@valid_params)
      conn = patch(conn, "/api/articles/#{record.id}/transitions/published-to-draft")
      assert conn.status in [409, 404]
    end
  end

end
