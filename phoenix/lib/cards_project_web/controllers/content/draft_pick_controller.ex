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

  def create(conn, params) do
    case Content.create_draft_pick(params) do
      {:ok, draft_pick} ->
        conn
        |> put_status(:created)
        |> json(serialize_draft_pick(draft_pick))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    draft_pick = Content.get_draft_pick!(id)
    case Content.update_draft_pick(draft_pick, params) do
      {:ok, draft_pick} ->
        json(conn, serialize_draft_pick(draft_pick))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    draft_pick = Content.get_draft_pick!(id)
    Content.delete_draft_pick(draft_pick)
    send_resp(conn, :no_content, "")
  end

  defp serialize_draft_pick(%DraftPick{} = record) do
    Map.take(record, [:id, :pick_number, :pack_number, :picked_at, :participant_id, :card_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
