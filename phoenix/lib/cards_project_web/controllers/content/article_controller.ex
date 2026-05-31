defmodule CardsProjectWeb.Content.ArticleController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Content
  alias CardsProject.Content.Article

  def index(conn, params) do
    q = Map.get(params, "q")
    articles = Content.list_articles(q)
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

  # POST /api/articles/{id}/like
  def like(conn, %{"id" => id}) do
    Content.article_like_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # DELETE /api/articles/{id}/like
  def unlike(conn, %{"id" => id}) do
    Content.article_unlike_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # GET /api/articles/{id}/reading-time
  def reading_time_minutes(conn, %{"id" => id}) do
    result = Content.article_reading_time_minutes_behavior(id)
    json(conn, %{result: result})
  end

  # PATCH /api/articles/:id/transitions/draft-to-published
  def transition_draft_to_published(conn, %{"id" => id}) do
    article = Content.get_article!(id)
    case Content.transition_draft_to_published_article(article) do
      {:ok, updated} ->
        json(conn, serialize_article(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  # PATCH /api/articles/:id/transitions/published-to-archived
  def transition_published_to_archived(conn, %{"id" => id}) do
    article = Content.get_article!(id)
    case Content.transition_published_to_archived_article(article) do
      {:ok, updated} ->
        json(conn, serialize_article(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  # PATCH /api/articles/:id/transitions/archived-to-draft
  def transition_archived_to_draft(conn, %{"id" => id}) do
    article = Content.get_article!(id)
    case Content.transition_archived_to_draft_article(article) do
      {:ok, updated} ->
        json(conn, serialize_article(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  # PATCH /api/articles/:id/transitions/published-to-draft
  def transition_published_to_draft(conn, %{"id" => _id}) do
    conn
    |> put_status(:conflict)
    |> json(%{error: "Transition Published -> Draft is not allowed"})
  end

  defp serialize_article(%Article{} = record) do
    record
    |> Map.take([:id, :title, :slug, :body, :excerpt, :cover_image_url, :status, :article_type, :language, :view_count, :likes_count, :is_featured, :published_at, :created_at, :updated_at, :author_id, :featured_deck_id, :comments_id])
    |> (fn m -> Map.put(Map.delete(m, :created_at), :created_at, Map.get(m, :created_at)) end).()
    |> (fn m -> Map.put(Map.delete(m, :updated_at), :updated_at, Map.get(m, :updated_at)) end).()
    |> (fn m -> Map.put(Map.delete(m, :published_at), :published_at, Map.get(m, :published_at)) end).()
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
