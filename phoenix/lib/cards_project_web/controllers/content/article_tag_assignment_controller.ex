defmodule CardsProjectWeb.Content.ArticleTagAssignmentController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Content
  alias CardsProject.Content.ArticleTagAssignment

  def index(conn, _params) do
    article_tag_assignments = Content.list_article_tag_assignments()
    json(conn, Enum.map(article_tag_assignments, &serialize_article_tag_assignment/1))
  end

  def show(conn, %{"id" => id}) do
    article_tag_assignment = Content.get_article_tag_assignment!(id)
    json(conn, serialize_article_tag_assignment(article_tag_assignment))
  end

  def create(conn, params) do
    case Content.create_article_tag_assignment(params) do
      {:ok, article_tag_assignment} ->
        conn
        |> put_status(:created)
        |> json(serialize_article_tag_assignment(article_tag_assignment))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    article_tag_assignment = Content.get_article_tag_assignment!(id)
    case Content.update_article_tag_assignment(article_tag_assignment, params) do
      {:ok, article_tag_assignment} ->
        json(conn, serialize_article_tag_assignment(article_tag_assignment))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    article_tag_assignment = Content.get_article_tag_assignment!(id)
    Content.delete_article_tag_assignment(article_tag_assignment)
    send_resp(conn, :no_content, "")
  end

  defp serialize_article_tag_assignment(%ArticleTagAssignment{} = record) do
    Map.take(record, [:id, :article_id, :tag_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
