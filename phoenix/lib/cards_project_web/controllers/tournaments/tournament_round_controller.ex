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

  def update(conn, %{"id" => id} = params) do
    tournament_round = Tournaments.get_tournament_round!(id)
    case Tournaments.update_tournament_round(tournament_round, params) do
      {:ok, tournament_round} ->
        json(conn, serialize_tournament_round(tournament_round))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    tournament_round = Tournaments.get_tournament_round!(id)
    Tournaments.delete_tournament_round(tournament_round)
    send_resp(conn, :no_content, "")
  end

  defp serialize_tournament_round(%TournamentRound{} = record) do
    Map.take(record, [:id, :round_number, :status, :started_at, :ended_at, :time_limit_minutes, :tournament_id, :matches_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
