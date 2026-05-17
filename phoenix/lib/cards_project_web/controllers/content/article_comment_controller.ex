defmodule CardsProjectWeb.Content.ArticleCommentController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Content
  alias CardsProject.Content.ArticleComment

  def index(conn, _params) do
    article_comments = Content.list_article_comments()
    json(conn, Enum.map(article_comments, &serialize_article_comment/1))
  end

  def show(conn, %{"id" => id}) do
    article_comment = Content.get_article_comment!(id)
    json(conn, serialize_article_comment(article_comment))
  end

  def create(conn, params) do
    case Content.create_article_comment(params) do
      {:ok, article_comment} ->
        conn
        |> put_status(:created)
        |> json(serialize_article_comment(article_comment))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    article_comment = Content.get_article_comment!(id)
    case Content.update_article_comment(article_comment, params) do
      {:ok, article_comment} ->
        json(conn, serialize_article_comment(article_comment))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    article_comment = Content.get_article_comment!(id)
    Content.delete_article_comment(article_comment)
    send_resp(conn, :no_content, "")
  end

  # POST /api/comments/{id}/hide
  def hide(conn, %{"id" => id}) do
    Content.article_comment_hide_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/comments/{id}/unhide
  def unhide(conn, %{"id" => id}) do
    Content.article_comment_unhide_behavior(id)
    send_resp(conn, :no_content, "")
  end

  defp serialize_article_comment(%ArticleComment{} = record) do
    Map.take(record, [:id, :body, :is_hidden, :created_at, :article_id, :author_id, :parent_comment_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
