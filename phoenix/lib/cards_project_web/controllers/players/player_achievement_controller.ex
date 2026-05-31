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
    record
    |> Map.take([:id, :earned_at, :progress, :is_completed, :player_id, :achievement_id])
    |> (fn m -> Map.put(Map.delete(m, :earned_at), :earned_at, Map.get(m, :earned_at)) end).()
  end

end
