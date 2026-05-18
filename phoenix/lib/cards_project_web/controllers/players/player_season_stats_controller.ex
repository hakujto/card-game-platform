defmodule CardsProjectWeb.Players.PlayerSeasonStatsController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Players
  alias CardsProject.Players.PlayerSeasonStats

  def index(conn, _params) do
    player_season_statses = Players.list_player_season_statses()
    json(conn, Enum.map(player_season_statses, &serialize_player_season_stats/1))
  end

  def show(conn, %{"id" => id}) do
    player_season_stats = Players.get_player_season_stats!(id)
    json(conn, serialize_player_season_stats(player_season_stats))
  end

  def create(conn, params) do
    case Players.create_player_season_stats(params) do
      {:ok, player_season_stats} ->
        conn
        |> put_status(:created)
        |> json(serialize_player_season_stats(player_season_stats))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    player_season_stats = Players.get_player_season_stats!(id)
    case Players.update_player_season_stats(player_season_stats, params) do
      {:ok, player_season_stats} ->
        json(conn, serialize_player_season_stats(player_season_stats))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    player_season_stats = Players.get_player_season_stats!(id)
    Players.delete_player_season_stats(player_season_stats)
    send_resp(conn, :no_content, "")
  end

  # GET /api/player-season-stats/{id}/win-rate
  def win_rate(conn, %{"id" => id}) do
    result = Players.player_season_stats_win_rate_behavior(id)
    json(conn, %{result: result})
  end

  # PATCH /api/player-season-stats/{id}/points
  def add_points(conn, %{"id" => id} = params) do
    points = Map.get(params, "points")
    Players.player_season_stats_add_points_behavior(id, points)
    send_resp(conn, :no_content, "")
  end

  # POST /api/player-season-stats/{id}/tournament-win
  def record_tournament_win(conn, %{"id" => id}) do
    Players.player_season_stats_record_tournament_win_behavior(id)
    send_resp(conn, :no_content, "")
  end

  defp serialize_player_season_stats(%PlayerSeasonStats{} = record) do
    Map.take(record, [:id, :wins, :losses, :draws, :tournament_wins, :highest_rank, :season_points, :player_id, :season_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
