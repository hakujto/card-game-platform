defmodule CardsProjectWeb.Players.PlayerAchievementController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Players
  alias CardsProject.Players.PlayerAchievement

  def index(conn, _params) do
    player_achievements = Players.list_player_achievements()
    json(conn, Enum.map(player_achievements, &serialize_player_achievement/1))
  end

  def show(conn, %{"id" => id}) do
    player_achievement = Players.get_player_achievement!(id)
    json(conn, serialize_player_achievement(player_achievement))
  end

  def create(conn, params) do
    case Players.create_player_achievement(params) do
      {:ok, player_achievement} ->
        conn
        |> put_status(:created)
        |> json(serialize_player_achievement(player_achievement))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    player_achievement = Players.get_player_achievement!(id)
    case Players.update_player_achievement(player_achievement, params) do
      {:ok, player_achievement} ->
        json(conn, serialize_player_achievement(player_achievement))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    player_achievement = Players.get_player_achievement!(id)
    Players.delete_player_achievement(player_achievement)
    send_resp(conn, :no_content, "")
  end

  # PATCH /api/player-achievements/{id}/progress
  def increment_progress(conn, %{"id" => id} = params) do
    amount = Map.get(params, "amount")
    Players.player_achievement_increment_progress_behavior(id, amount)
    send_resp(conn, :no_content, "")
  end

  # POST /api/player-achievements/{id}/complete
  def complete(conn, %{"id" => id}) do
    Players.player_achievement_complete_behavior(id)
    send_resp(conn, :no_content, "")
  end

  defp serialize_player_achievement(%PlayerAchievement{} = record) do
    Map.take(record, [:id, :earned_at, :progress, :is_completed, :player_id, :achievement_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
