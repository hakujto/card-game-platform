defmodule CardsProjectWeb.Cards.DeckTagController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Cards
  alias CardsProject.Cards.DeckTag

  def index(conn, _params) do
    deck_tags = Cards.list_deck_tags()
    json(conn, Enum.map(deck_tags, &serialize_deck_tag/1))
  end

  def show(conn, %{"id" => id}) do
    deck_tag = Cards.get_deck_tag!(id)
    json(conn, serialize_deck_tag(deck_tag))
  end

  def create(conn, params) do
    case Cards.create_deck_tag(params) do
      {:ok, deck_tag} ->
        conn
        |> put_status(:created)
        |> json(serialize_deck_tag(deck_tag))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    deck_tag = Cards.get_deck_tag!(id)
    case Cards.update_deck_tag(deck_tag, params) do
      {:ok, deck_tag} ->
        json(conn, serialize_deck_tag(deck_tag))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    deck_tag = Cards.get_deck_tag!(id)
    Cards.delete_deck_tag(deck_tag)
    send_resp(conn, :no_content, "")
  end

  # POST /api/deck-tags/{id}/merge
  def merge_into(conn, %{"id" => id} = params) do
    target_tag_id = Map.get(params, "target_tag_id")
    Cards.deck_tag_merge_into_behavior(id, target_tag_id)
    send_resp(conn, :no_content, "")
  end

  defp serialize_deck_tag(%DeckTag{} = record) do
    Map.take(record, [:id, :name, :color])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
