defmodule CardsProjectWeb.Content.ArticleTagAssignmentControllerTest do
  use ExUnit.Case, async: true
  use CardsProjectWeb.ConnCase

  @valid_params %{}

  describe "GET /api/article_tag_assignments" do
    test "returns 200 with list", %{conn: conn} do
      conn = get(conn, "/api/article_tag_assignments")
      assert json_response(conn, 200) |> is_list()
    end
  end

  describe "POST /api/article_tag_assignments" do
    test "creates record and returns 201", %{conn: conn} do
      conn = post(conn, "/api/article_tag_assignments", @valid_params)
      assert %{"id" => _id} = json_response(conn, 201)
    end
  end

  describe "GET /api/article_tag_assignments/:id" do
    test "returns 200 for existing record", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_article_tag_assignment(@valid_params)
      conn = get(conn, "/api/article_tag_assignments/#{record.id}")
      assert json_response(conn, 200)
    end
  end

  describe "PUT /api/article_tag_assignments/:id" do
    test "updates and returns 200", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_article_tag_assignment(@valid_params)
      conn = put(conn, "/api/article_tag_assignments/#{record.id}", @valid_params)
      assert json_response(conn, 200)
    end
  end

  describe "DELETE /api/article_tag_assignments/:id" do
    test "deletes and returns 204", %{conn: conn} do
      {:ok, record} = CardsProject.Content.create_article_tag_assignment(@valid_params)
      conn = delete(conn, "/api/article_tag_assignments/#{record.id}")
      assert response(conn, 204)
    end
  end
end
