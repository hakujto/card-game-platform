defmodule CardsProjectWeb.Tournaments.GameController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Tournaments
  alias CardsProject.Tournaments.Game

  def index(conn, _params) do
    games = Tournaments.list_games()
    json(conn, Enum.map(games, &serialize_game/1))
  end

  def show(conn, %{"id" => id}) do
    game = Tournaments.get_game!(id)
    json(conn, serialize_game(game))
  end

  def create(conn, params) do
    case Tournaments.create_game(params) do
      {:ok, game} ->
        conn
        |> put_status(:created)
        |> json(serialize_game(game))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    game = Tournaments.get_game!(id)
    case Tournaments.update_game(game, params) do
      {:ok, game} ->
        json(conn, serialize_game(game))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    game = Tournaments.get_game!(id)
    Tournaments.delete_game(game)
    send_resp(conn, :no_content, "")
  end

  # POST /api/games/{id}/winner
  def record_winner(conn, %{"id" => id} = params) do
    winner_side = Map.get(params, "winner_side")
    Tournaments.game_record_winner_behavior(id, winner_side)
    send_resp(conn, :no_content, "")
  end

  defp serialize_game(%Game{} = record) do
    Map.take(record, [:id, :game_number, :winner_side, :turns_played, :duration_seconds, :ended_by, :replay_url, :match_id, :winner_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
