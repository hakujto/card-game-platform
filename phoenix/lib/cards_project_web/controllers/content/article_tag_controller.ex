defmodule CardsProjectWeb.Content.ArticleTagController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Content
  alias CardsProject.Content.ArticleTag

  def index(conn, _params) do
    article_tags = Content.list_article_tags()
    json(conn, Enum.map(article_tags, &serialize_article_tag/1))
  end

  def show(conn, %{"id" => id}) do
    article_tag = Content.get_article_tag!(id)
    json(conn, serialize_article_tag(article_tag))
  end

  def create(conn, params) do
    case Content.create_article_tag(params) do
      {:ok, article_tag} ->
        conn
        |> put_status(:created)
        |> json(serialize_article_tag(article_tag))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    article_tag = Content.get_article_tag!(id)
    case Content.update_article_tag(article_tag, params) do
      {:ok, article_tag} ->
        json(conn, serialize_article_tag(article_tag))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    article_tag = Content.get_article_tag!(id)
    Content.delete_article_tag(article_tag)
    send_resp(conn, :no_content, "")
  end

  defp serialize_article_tag(%ArticleTag{} = record) do
    Map.take(record, [:id, :name, :slug])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
