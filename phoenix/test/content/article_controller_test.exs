defmodule CardsProjectWeb.Content.ArticleControllerTest do
  use ExUnit.Case, async: true
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "title" => "test",
    "slug" => "test",
    "body" => "test",
    "status" => "test",
    "article_type" => "test",
    "view_count" => 0,
    "created_at" => ~N[2024-01-01 00:00:00],
    "updated_at" => ~N[2024-01-01 00:00:00],
    "status" => "Draft",
    "article_type" => "Guide"
  }

  describe "GET /api/articles" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/articles")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/articles" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/articles", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
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

  describe "DELETE /api/articles/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_article(@valid_params)
      conn = delete(conn, "/api/articles/#{record.id}")
      assert response(conn, 204)
    end
  end
end
