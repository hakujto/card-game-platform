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

  # PATCH /api/draft_sessions/:id/transitions/waitingforplayers-to-drafting
  def transition_waiting_for_players_to_drafting(conn, %{"id" => id}) do
    draft_session = Content.get_draft_session!(id)
    case Content.transition_waiting_for_players_to_drafting_draft_session(draft_session) do
      {:ok, updated} ->
        json(conn, serialize_draft_session(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  # PATCH /api/draft_sessions/:id/transitions/drafting-to-completed
  def transition_drafting_to_completed(conn, %{"id" => id}) do
    draft_session = Content.get_draft_session!(id)
    case Content.transition_drafting_to_completed_draft_session(draft_session) do
      {:ok, updated} ->
        json(conn, serialize_draft_session(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  # PATCH /api/draft_sessions/:id/transitions/drafting-to-abandoned
  def transition_drafting_to_abandoned(conn, %{"id" => id}) do
    user_role = conn.assigns[:current_user] && conn.assigns[:current_user].role
    unless user_role in ["Admin", "Organizer"] do
      conn |> put_status(:forbidden) |> json(%{error: "Insufficient role for transition Drafting -> Abandoned"}) |> halt()
    else
    draft_session = Content.get_draft_session!(id)
    case Content.transition_drafting_to_abandoned_draft_session(draft_session) do
      {:ok, updated} ->
        json(conn, serialize_draft_session(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
    end
  end

  # PATCH /api/draft_sessions/:id/transitions/waitingforplayers-to-abandoned
  def transition_waiting_for_players_to_abandoned(conn, %{"id" => id}) do
    user_role = conn.assigns[:current_user] && conn.assigns[:current_user].role
    unless user_role in ["Admin", "Organizer"] do
      conn |> put_status(:forbidden) |> json(%{error: "Insufficient role for transition WaitingForPlayers -> Abandoned"}) |> halt()
    else
    draft_session = Content.get_draft_session!(id)
    case Content.transition_waiting_for_players_to_abandoned_draft_session(draft_session) do
      {:ok, updated} ->
        json(conn, serialize_draft_session(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
    end
  end

  # PATCH /api/draft_sessions/:id/transitions/completed-to-drafting
  def transition_completed_to_drafting(conn, %{"id" => _id}) do
    conn
    |> put_status(:conflict)
    |> json(%{error: "Transition Completed -> Drafting is not allowed"})
  end

  # PATCH /api/draft_sessions/:id/transitions/abandoned-to-drafting
  def transition_abandoned_to_drafting(conn, %{"id" => _id}) do
    conn
    |> put_status(:conflict)
    |> json(%{error: "Transition Abandoned -> Drafting is not allowed"})
  end

  defp serialize_draft_session(%DraftSession{} = record) do
    record
    |> Map.take([:id, :status, :draft_type, :seats, :time_per_pick_seconds, :created_at, :completed_at, :card_set_id, :participants_id])
    |> (fn m -> Map.put(Map.delete(m, :created_at), :created_at, Map.get(m, :created_at)) end).()
    |> (fn m -> Map.put(Map.delete(m, :completed_at), :completed_at, Map.get(m, :completed_at)) end).()
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
