defmodule CardsProjectWeb.Content.DraftSessionController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Content
  alias CardsProject.Content.DraftSession

  def index(conn, _params) do
    draft_sessions = Content.list_draft_sessions()
    json(conn, Enum.map(draft_sessions, &serialize_draft_session/1))
  end

  def show(conn, %{"id" => id}) do
    draft_session = Content.get_draft_session!(id)
    json(conn, serialize_draft_session(draft_session))
  end

  def create(conn, params) do
    case Content.create_draft_session(params) do
      {:ok, draft_session} ->
        conn
        |> put_status(:created)
        |> json(serialize_draft_session(draft_session))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    draft_session = Content.get_draft_session!(id)
    case Content.update_draft_session(draft_session, params) do
      {:ok, draft_session} ->
        json(conn, serialize_draft_session(draft_session))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    draft_session = Content.get_draft_session!(id)
    Content.delete_draft_session(draft_session)
    send_resp(conn, :no_content, "")
  end

  # POST /api/draft-sessions/{id}/start
  def start(conn, %{"id" => id}) do
    Content.draft_session_start_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/draft-sessions/{id}/abandon
  def abandon(conn, %{"id" => id}) do
    Content.draft_session_abandon_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/draft-sessions/{id}/complete
  def complete(conn, %{"id" => id}) do
    Content.draft_session_complete_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # GET /api/draft-sessions/{id}/full
  def is_full(conn, %{"id" => id}) do
    result = Content.draft_session_is_full_behavior(id)
    json(conn, %{result: result})
  end

  defp serialize_draft_session(%DraftSession{} = record) do
    Map.take(record, [:id, :status, :draft_type, :seats, :created_at, :completed_at, :card_set_id, :participants_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
