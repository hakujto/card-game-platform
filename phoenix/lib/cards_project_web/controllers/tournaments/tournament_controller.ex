defmodule CardsProjectWeb.Tournaments.TournamentController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Tournaments
  alias CardsProject.Tournaments.Tournament

  def index(conn, params) do
    q = Map.get(params, "q")
    tournaments = Tournaments.list_tournaments(q)
    json(conn, Enum.map(tournaments, &serialize_tournament/1))
  end

  def show(conn, %{"id" => id}) do
    tournament = Tournaments.get_tournament!(id)
    json(conn, serialize_tournament(tournament))
  end

  def create(conn, params) do
    case Tournaments.create_tournament(params) do
      {:ok, tournament} ->
        conn
        |> put_status(:created)
        |> json(serialize_tournament(tournament))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    tournament = Tournaments.get_tournament!(id)
    case Tournaments.update_tournament(tournament, params) do
      {:ok, tournament} ->
        json(conn, serialize_tournament(tournament))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  # POST /api/tournaments/{id}/start
  def start(conn, %{"id" => id}) do
    Tournaments.tournament_start_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/tournaments/{id}/cancel
  def cancel(conn, %{"id" => id}) do
    Tournaments.tournament_cancel_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/tournaments/{id}/complete
  def complete(conn, %{"id" => id}) do
    Tournaments.tournament_complete_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/tournaments/{id}/rounds
  def generate_round(conn, %{"id" => id}) do
    Tournaments.tournament_generate_round_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # GET /api/tournaments/{id}/prizes
  def calculate_prize_distribution(conn, %{"id" => id}) do
    result = Tournaments.tournament_calculate_prize_distribution_behavior(id)
    json(conn, %{result: result})
  end

  # POST /api/tournaments/{id}/register
  def register_player(conn, %{"id" => id} = params) do
    player_id = Map.get(params, "player_id")
    deck_id = Map.get(params, "deck_id")
    Tournaments.tournament_register_player_behavior(id, player_id, deck_id)
    send_resp(conn, :no_content, "")
  end

  # GET /api/tournaments/{id}/full
  def is_full(conn, %{"id" => id}) do
    result = Tournaments.tournament_is_full_behavior(id)
    json(conn, %{result: result})
  end

  # PATCH /api/tournaments/:id/transitions/draft-to-registration
  def transition_draft_to_registration(conn, %{"id" => id}) do
    tournament = Tournaments.get_tournament!(id)
    case Tournaments.transition_draft_to_registration_tournament(tournament) do
      {:ok, updated} ->
        json(conn, serialize_tournament(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  # PATCH /api/tournaments/:id/transitions/registration-to-ongoing
  def transition_registration_to_ongoing(conn, %{"id" => id}) do
    tournament = Tournaments.get_tournament!(id)
    case Tournaments.transition_registration_to_ongoing_tournament(tournament) do
      {:ok, updated} ->
        json(conn, serialize_tournament(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  # PATCH /api/tournaments/:id/transitions/registration-to-cancelled
  def transition_registration_to_cancelled(conn, %{"id" => id}) do
    tournament = Tournaments.get_tournament!(id)
    case Tournaments.transition_registration_to_cancelled_tournament(tournament) do
      {:ok, updated} ->
        json(conn, serialize_tournament(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  # PATCH /api/tournaments/:id/transitions/ongoing-to-completed
  def transition_ongoing_to_completed(conn, %{"id" => id}) do
    tournament = Tournaments.get_tournament!(id)
    case Tournaments.transition_ongoing_to_completed_tournament(tournament) do
      {:ok, updated} ->
        json(conn, serialize_tournament(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  # PATCH /api/tournaments/:id/transitions/ongoing-to-cancelled
  def transition_ongoing_to_cancelled(conn, %{"id" => id}) do
    tournament = Tournaments.get_tournament!(id)
    case Tournaments.transition_ongoing_to_cancelled_tournament(tournament) do
      {:ok, updated} ->
        json(conn, serialize_tournament(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  # PATCH /api/tournaments/:id/transitions/completed-to-draft
  def transition_completed_to_draft(conn, %{"id" => _id}) do
    conn
    |> put_status(:conflict)
    |> json(%{error: "Transition Completed -> Draft is not allowed"})
  end

  # PATCH /api/tournaments/:id/transitions/cancelled-to-draft
  def transition_cancelled_to_draft(conn, %{"id" => _id}) do
    conn
    |> put_status(:conflict)
    |> json(%{error: "Transition Cancelled -> Draft is not allowed"})
  end

  defp serialize_tournament(%Tournament{} = record) do
    record
    |> Map.take([:id, :name, :description, :status, :format, :tournament_type, :max_players, :entry_fee, :prize_pool, :start_time, :end_time, :is_online, :location, :rules_text, :created_at, :season_id, :organizer_id, :registrations_id, :rounds_id, :prizes_id])
    |> (fn m -> Map.put(Map.delete(m, :created_at), :created_at, Map.get(m, :created_at)) end).()
    |> (fn m -> Map.put(Map.delete(m, :start_time), :start_time, Map.get(m, :start_time)) end).()
    |> (fn m -> Map.put(Map.delete(m, :end_time), :end_time, Map.get(m, :end_time)) end).()
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
