defmodule CardsProjectWeb.Tournaments.TournamentPrizeController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Tournaments
  alias CardsProject.Tournaments.TournamentPrize

  def index(conn, _params) do
    tournament_prizes = Tournaments.list_tournament_prizes()
    json(conn, Enum.map(tournament_prizes, &serialize_tournament_prize/1))
  end

  def show(conn, %{"id" => id}) do
    tournament_prize = Tournaments.get_tournament_prize!(id)
    json(conn, serialize_tournament_prize(tournament_prize))
  end

  def create(conn, params) do
    case Tournaments.create_tournament_prize(params) do
      {:ok, tournament_prize} ->
        conn
        |> put_status(:created)
        |> json(serialize_tournament_prize(tournament_prize))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    tournament_prize = Tournaments.get_tournament_prize!(id)
    case Tournaments.update_tournament_prize(tournament_prize, params) do
      {:ok, tournament_prize} ->
        json(conn, serialize_tournament_prize(tournament_prize))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    tournament_prize = Tournaments.get_tournament_prize!(id)
    Tournaments.delete_tournament_prize(tournament_prize)
    send_resp(conn, :no_content, "")
  end

  # GET /api/prizes/{id}/applies
  def applies_to_placement(conn, %{"id" => id} = params) do
    placement = Map.get(params, "placement")
    result = Tournaments.tournament_prize_applies_to_placement_behavior(id, placement)
    json(conn, %{result: result})
  end

  # POST /api/prizes/{id}/award
  def award_to_player(conn, %{"id" => id} = params) do
    player_id = Map.get(params, "player_id")
    Tournaments.tournament_prize_award_to_player_behavior(id, player_id)
    send_resp(conn, :no_content, "")
  end

  defp serialize_tournament_prize(%TournamentPrize{} = record) do
    Map.take(record, [:id, :placement_from, :placement_to, :prize_type, :amount, :description, :packs_count, :season_points, :tournament_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
