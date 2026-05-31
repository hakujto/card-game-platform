defmodule CardsProjectWeb.Content.DraftPickController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Content
  alias CardsProject.Content.DraftPick

  def index(conn, _params) do
    draft_picks = Content.list_draft_picks()
    json(conn, Enum.map(draft_picks, &serialize_draft_pick/1))
  end

  def show(conn, %{"id" => id}) do
    draft_pick = Content.get_draft_pick!(id)
    json(conn, serialize_draft_pick(draft_pick))
  end

  # GET /api/draft-picks/{id}/first-pick
  def is_first_pick(conn, %{"id" => id}) do
    result = Content.draft_pick_is_first_pick_behavior(id)
    json(conn, %{result: result})
  end

  defp serialize_draft_pick(%DraftPick{} = record) do
    record
    |> Map.take([:id, :pick_number, :pack_number, :picked_at, :participant_id, :card_id])
    |> (fn m -> Map.put(Map.delete(m, :picked_at), :picked_at, Map.get(m, :picked_at)) end).()
  end

end
