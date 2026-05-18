defmodule CardsProjectWeb.Content.ArticleController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Content
  alias CardsProject.Content.Article

  def index(conn, _params) do
    articles = Content.list_articles()
    json(conn, Enum.map(articles, &serialize_article/1))
  end

  def show(conn, %{"id" => id}) do
    article = Content.get_article!(id)
    json(conn, serialize_article(article))
  end

  def create(conn, params) do
    case Content.create_article(params) do
      {:ok, article} ->
        conn
        |> put_status(:created)
        |> json(serialize_article(article))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    article = Content.get_article!(id)
    case Content.update_article(article, params) do
      {:ok, article} ->
        json(conn, serialize_article(article))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    article = Content.get_article!(id)
    Content.delete_article(article)
    send_resp(conn, :no_content, "")
  end

  # POST /api/articles/{id}/publish
  def publish(conn, %{"id" => id}) do
    Content.article_publish_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/articles/{id}/archive
  def archive(conn, %{"id" => id}) do
    Content.article_archive_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/articles/{id}/view
  def increment_view(conn, %{"id" => id}) do
    Content.article_increment_view_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # GET /api/articles/{id}/reading-time
  def reading_time_minutes(conn, %{"id" => id}) do
    result = Content.article_reading_time_minutes_behavior(id)
    json(conn, %{result: result})
  end

  defp serialize_article(%Article{} = record) do
    Map.take(record, [:id, :title, :slug, :body, :excerpt, :cover_image_url, :status, :article_type, :view_count, :published_at, :created_at, :updated_at, :author_id, :featured_deck_id, :comments_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
