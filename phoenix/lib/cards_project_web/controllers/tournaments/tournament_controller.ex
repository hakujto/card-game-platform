defmodule CardsProjectWeb.Tournaments.TournamentController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Tournaments
  alias CardsProject.Tournaments.Tournament

  def index(conn, _params) do
    tournaments = Tournaments.list_tournaments()
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

  def delete(conn, %{"id" => id}) do
    tournament = Tournaments.get_tournament!(id)
    Tournaments.delete_tournament(tournament)
    send_resp(conn, :no_content, "")
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

  defp serialize_tournament(%Tournament{} = record) do
    Map.take(record, [:id, :name, :description, :format, :tournament_type, :status, :max_players, :entry_fee, :prize_pool, :start_time, :end_time, :is_online, :location, :rules_text, :created_at, :season_id, :organizer_id, :registrations_id, :rounds_id, :prizes_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
