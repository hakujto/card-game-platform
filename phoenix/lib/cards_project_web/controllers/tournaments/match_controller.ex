defmodule CardsProjectWeb.Tournaments.MatchController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Tournaments
  alias CardsProject.Tournaments.Match

  def index(conn, _params) do
    matches = Tournaments.list_matches()
    json(conn, Enum.map(matches, &serialize_match/1))
  end

  def show(conn, %{"id" => id}) do
    match = Tournaments.get_match!(id)
    json(conn, serialize_match(match))
  end

  def create(conn, params) do
    case Tournaments.create_match(params) do
      {:ok, match} ->
        conn
        |> put_status(:created)
        |> json(serialize_match(match))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  # POST /api/matches/{id}/record
  def record_result(conn, %{"id" => id} = params) do
    p1_wins = Map.get(params, "p1_wins")
    p2_wins = Map.get(params, "p2_wins")
    Tournaments.match_record_result_behavior(id, p1_wins, p2_wins)
    send_resp(conn, :no_content, "")
  end

  # POST /api/matches/{id}/finalize
  def finalize_result(conn, %{"id" => id}) do
    Tournaments.match_finalize_result_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # GET /api/matches/{id}/winner
  def determine_winner(conn, %{"id" => id}) do
    result = Tournaments.match_determine_winner_behavior(id)
    json(conn, %{result: result})
  end

  # POST /api/matches/{id}/concede
  def concede(conn, %{"id" => id} = params) do
    player_id = Map.get(params, "player_id")
    obj = Tournaments.get_match!(id)
    if not (obj.status == "Active") do
      conn |> put_status(:unprocessable_entity) |> json(%{error: "Guard condition not met for concede"}) |> halt()
    else
      Tournaments.match_concede_behavior(id, player_id)
      send_resp(conn, :no_content, "")
    end
  end

  # POST /api/matches/{id}/draw
  def draw(conn, %{"id" => id}) do
    Tournaments.match_draw_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # PATCH /api/matches/:id/transitions/pending-to-active
  def transition_pending_to_active(conn, %{"id" => id}) do
    user_role = conn.assigns[:current_user] && conn.assigns[:current_user].role
    unless user_role in ["Judge", "HeadJudge", "Admin"] do
      conn |> put_status(:forbidden) |> json(%{error: "Insufficient role for transition Pending -> Active"}) |> halt()
    else
    match = Tournaments.get_match!(id)
    case Tournaments.transition_pending_to_active_match(match) do
      {:ok, updated} ->
        json(conn, serialize_match(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
    end
  end

  # PATCH /api/matches/:id/transitions/active-to-completed
  def transition_active_to_completed(conn, %{"id" => id}) do
    user_role = conn.assigns[:current_user] && conn.assigns[:current_user].role
    unless user_role in ["Judge", "HeadJudge", "Admin"] do
      conn |> put_status(:forbidden) |> json(%{error: "Insufficient role for transition Active -> Completed"}) |> halt()
    else
    match = Tournaments.get_match!(id)
    case Tournaments.transition_active_to_completed_match(match) do
      {:ok, updated} ->
        json(conn, serialize_match(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
    end
  end

  # PATCH /api/matches/:id/transitions/active-to-draw
  def transition_active_to_draw(conn, %{"id" => id}) do
    user_role = conn.assigns[:current_user] && conn.assigns[:current_user].role
    unless user_role in ["Judge", "HeadJudge", "Admin"] do
      conn |> put_status(:forbidden) |> json(%{error: "Insufficient role for transition Active -> Draw"}) |> halt()
    else
    match = Tournaments.get_match!(id)
    case Tournaments.transition_active_to_draw_match(match) do
      {:ok, updated} ->
        json(conn, serialize_match(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
    end
  end

  # PATCH /api/matches/:id/transitions/pending-to-bye
  def transition_pending_to_b_y_e(conn, %{"id" => id}) do
    user_role = conn.assigns[:current_user] && conn.assigns[:current_user].role
    unless user_role in ["Judge", "HeadJudge", "Admin"] do
      conn |> put_status(:forbidden) |> json(%{error: "Insufficient role for transition Pending -> BYE"}) |> halt()
    else
    match = Tournaments.get_match!(id)
    case Tournaments.transition_pending_to_b_y_e_match(match) do
      {:ok, updated} ->
        json(conn, serialize_match(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
    end
  end

  # PATCH /api/matches/:id/transitions/completed-to-active
  def transition_completed_to_active(conn, %{"id" => _id}) do
    conn
    |> put_status(:conflict)
    |> json(%{error: "Transition Completed -> Active is not allowed"})
  end

  # PATCH /api/matches/:id/transitions/draw-to-active
  def transition_draw_to_active(conn, %{"id" => _id}) do
    conn
    |> put_status(:conflict)
    |> json(%{error: "Transition Draw -> Active is not allowed"})
  end

  # PATCH /api/matches/:id/transitions/bye-to-active
  def transition_b_y_e_to_active(conn, %{"id" => _id}) do
    conn
    |> put_status(:conflict)
    |> json(%{error: "Transition BYE -> Active is not allowed"})
  end

  defp serialize_match(%Match{} = record) do
    record
    |> Map.take([:id, :table_number, :status, :player1_wins, :player2_wins, :started_at, :ended_at, :result_notes, :round_id, :player1_id, :player2_id, :games_id])
    |> (fn m -> Map.put(Map.delete(m, :started_at), :started_at, Map.get(m, :started_at)) end).()
    |> (fn m -> Map.put(Map.delete(m, :ended_at), :ended_at, Map.get(m, :ended_at)) end).()
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
