defmodule CardsProjectWeb.Tournaments.AwardedPrizeController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Tournaments
  alias CardsProject.Tournaments.AwardedPrize

  def index(conn, _params) do
    awarded_prizes = Tournaments.list_awarded_prizes()
    json(conn, Enum.map(awarded_prizes, &serialize_awarded_prize/1))
  end

  def show(conn, %{"id" => id}) do
    awarded_prize = Tournaments.get_awarded_prize!(id)
    json(conn, serialize_awarded_prize(awarded_prize))
  end

  # POST /api/awarded-prizes/{id}/claim
  def claim(conn, %{"id" => id}) do
    Tournaments.awarded_prize_claim_behavior(id)
    send_resp(conn, :no_content, "")
  end

  defp serialize_awarded_prize(%AwardedPrize{} = record) do
    record
    |> Map.take([:id, :final_placement, :awarded_at, :claimed, :claimed_at, :prize_id, :player_id])
    |> (fn m -> Map.put(Map.delete(m, :awarded_at), :awarded_at, Map.get(m, :awarded_at)) end).()
    |> (fn m -> Map.put(Map.delete(m, :claimed_at), :claimed_at, Map.get(m, :claimed_at)) end).()
  end

end
