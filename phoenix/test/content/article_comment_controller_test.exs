defmodule CardsProjectWeb.Content.ArticleCommentControllerTest do
  use ExUnit.Case, async: false
  use CardsProjectWeb.ConnCase

  @valid_params %{
    "body" => "test",
    "is_hidden" => true,
    "created_at" => ~N[2024-01-01 00:00:00]
  }

  describe "GET /api/article_comments" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/article_comments")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/article_comments" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/article_comments", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/article_comments/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_article_comment(@valid_params)
      conn = get(conn, "/api/article_comments/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/article_comments/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_article_comment(@valid_params)
      conn = put(conn, "/api/article_comments/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/article_comments/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_article_comment(@valid_params)
      conn = delete(conn, "/api/article_comments/#{record.id}")
      assert response(conn, 204)
    end
  end
end
