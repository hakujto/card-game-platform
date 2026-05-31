defmodule CardsProjectWeb.Tournaments.TournamentRoundController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Tournaments
  alias CardsProject.Tournaments.TournamentRound

  def index(conn, _params) do
    tournament_rounds = Tournaments.list_tournament_rounds()
    json(conn, Enum.map(tournament_rounds, &serialize_tournament_round/1))
  end

  def show(conn, %{"id" => id}) do
    tournament_round = Tournaments.get_tournament_round!(id)
    json(conn, serialize_tournament_round(tournament_round))
  end

  def create(conn, params) do
    case Tournaments.create_tournament_round(params) do
      {:ok, tournament_round} ->
        conn
        |> put_status(:created)
        |> json(serialize_tournament_round(tournament_round))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  # POST /api/rounds/{id}/start
  def start(conn, %{"id" => id}) do
    Tournaments.tournament_round_start_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/rounds/{id}/complete
  def complete(conn, %{"id" => id}) do
    Tournaments.tournament_round_complete_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/rounds/{id}/pairings
  def generate_pairings(conn, %{"id" => id}) do
    Tournaments.tournament_round_generate_pairings_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # GET /api/rounds/{id}/time-expired
  def is_time_expired(conn, %{"id" => id}) do
    result = Tournaments.tournament_round_is_time_expired_behavior(id)
    json(conn, %{result: result})
  end

  defp serialize_tournament_round(%TournamentRound{} = record) do
    record
    |> Map.take([:id, :round_number, :status, :started_at, :ended_at, :time_limit_minutes, :tournament_id, :matches_id])
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
