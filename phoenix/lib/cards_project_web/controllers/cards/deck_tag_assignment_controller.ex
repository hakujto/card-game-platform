defmodule CardsProjectWeb.Cards.DeckTagAssignmentController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Cards
  alias CardsProject.Cards.DeckTagAssignment

  def index(conn, _params) do
    deck_tag_assignments = Cards.list_deck_tag_assignments()
    json(conn, Enum.map(deck_tag_assignments, &serialize_deck_tag_assignment/1))
  end

  def show(conn, %{"id" => id}) do
    deck_tag_assignment = Cards.get_deck_tag_assignment!(id)
    json(conn, serialize_deck_tag_assignment(deck_tag_assignment))
  end

  def create(conn, params) do
    case Cards.create_deck_tag_assignment(params) do
      {:ok, deck_tag_assignment} ->
        conn
        |> put_status(:created)
        |> json(serialize_deck_tag_assignment(deck_tag_assignment))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    deck_tag_assignment = Cards.get_deck_tag_assignment!(id)
    case Cards.update_deck_tag_assignment(deck_tag_assignment, params) do
      {:ok, deck_tag_assignment} ->
        json(conn, serialize_deck_tag_assignment(deck_tag_assignment))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    deck_tag_assignment = Cards.get_deck_tag_assignment!(id)
    Cards.delete_deck_tag_assignment(deck_tag_assignment)
    send_resp(conn, :no_content, "")
  end

  defp serialize_deck_tag_assignment(%DeckTagAssignment{} = record) do
    Map.take(record, [:id, :deck_id, :tag_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
