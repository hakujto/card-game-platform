defmodule CardsProjectWeb.Content.DraftParticipantController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Content
  alias CardsProject.Content.DraftParticipant

  def index(conn, _params) do
    draft_participants = Content.list_draft_participants()
    json(conn, Enum.map(draft_participants, &serialize_draft_participant/1))
  end

  def show(conn, %{"id" => id}) do
    draft_participant = Content.get_draft_participant!(id)
    json(conn, serialize_draft_participant(draft_participant))
  end

  def create(conn, params) do
    case Content.create_draft_participant(params) do
      {:ok, draft_participant} ->
        conn
        |> put_status(:created)
        |> json(serialize_draft_participant(draft_participant))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    draft_participant = Content.get_draft_participant!(id)
    case Content.update_draft_participant(draft_participant, params) do
      {:ok, draft_participant} ->
        json(conn, serialize_draft_participant(draft_participant))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    draft_participant = Content.get_draft_participant!(id)
    Content.delete_draft_participant(draft_participant)
    send_resp(conn, :no_content, "")
  end

  # POST /api/draft-participants/{id}/pick
  def pick_card(conn, %{"id" => id} = params) do
    card_id = Map.get(params, "card_id")
    pack_number = Map.get(params, "pack_number")
    Content.draft_participant_pick_card_behavior(id, card_id, pack_number)
    send_resp(conn, :no_content, "")
  end

  # GET /api/draft-participants/{id}/card-count
  def drafted_card_count(conn, %{"id" => id}) do
    result = Content.draft_participant_drafted_card_count_behavior(id)
    json(conn, %{result: result})
  end

  defp serialize_draft_participant(%DraftParticipant{} = record) do
    Map.take(record, [:id, :seat_number, :joined_at, :session_id, :player_id, :drafted_cards_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
